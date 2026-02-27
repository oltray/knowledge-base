# ==============================================================================
# fetch.ps1 - Core fetch engine for Windows
# Reads sources.yaml and downloads/clones all documentation sources
#
# Usage:
#   .\scripts\fetch.ps1 [install|update]
#   install (default) - fresh clone/download
#   update            - git pull existing repos, skip existing files
# ==============================================================================

param(
    [ValidateSet("install","update")]
    [string]$Mode = "install"
)

$ScriptDir  = $PSScriptRoot
$RepoDir    = Split-Path $ScriptDir -Parent

. (Join-Path $ScriptDir "lib.ps1")
. (Join-Path $RepoDir "config\settings.ps1")

$SOURCES_FILE = $script:KB_SOURCES_FILE
$DOC_PATH     = $env:DOC_PATH

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Invoke-CurlDownload {
    param([string]$Url, [string]$Output)
    # curl.exe is built into Windows 10+.
    # Temporarily relax error handling so stderr output from curl does not
    # trigger a NativeCommandError and abort the script.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $allOutput = & curl.exe -fsSL --retry 3 --retry-delay 5 -o $Output $Url 2>&1
    $exit = $LASTEXITCODE
    $ErrorActionPreference = $prev
    foreach ($line in $allOutput) {
        if ($line -is [System.Management.Automation.ErrorRecord]) {
            Write-KbWarn "curl: $($line.Exception.Message)"
        } elseif ("$line".Trim()) {
            Write-KbWarn "curl: $line"
        }
    }
    return $exit
}

# ------------------------------------------------------------------------------
# Git sources
# ------------------------------------------------------------------------------

function Fetch-GitSources {
    Write-KbStep "Processing Git repositories"

    $count = & yq '.git | length' $SOURCES_FILE 2>$null
    if (-not $count -or $count -eq "0" -or $count -eq "null") {
        Write-KbWarn "No git sources defined in sources.yaml"
        return
    }

    $success = 0; $skipped = 0; $failed = 0

    for ($i = 0; $i -lt [int]$count; $i++) {
        $name     = (& yq ".git[$i].name"       $SOURCES_FILE).Trim()
        $url      = (& yq ".git[$i].url"        $SOURCES_FILE).Trim()
        $category = (& yq ".git[$i].category"   $SOURCES_FILE).Trim()
        $depth    = (& yq ".git[$i].depth // 1" $SOURCES_FILE).Trim()

        if (Test-SkipCategory $category) {
            Write-KbSkip "$name (category $category skipped)"
            $skipped++
            continue
        }

        $categoryDir = Join-Path $DOC_PATH $category
        $targetDir   = Join-Path $categoryDir $name
        Ensure-Dir $categoryDir

        if ($Mode -eq "update" -and (Test-Path (Join-Path $targetDir ".git"))) {
            Write-KbInfo "Updating $name..."
            $result = & git -C $targetDir pull --rebase --autostash -q 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-KbOk "$name updated"
                Write-KbToFile "INFO" "Updated git repo: $name"
                $success++
            } else {
                Write-KbError "Failed to update $name"
                Write-KbToFile "ERROR" "Failed to update git repo: $name"
                $failed++
            }
        } elseif (Test-Path (Join-Path $targetDir ".git")) {
            Write-KbSkip "$name (already cloned - run update.ps1 to refresh)"
            $skipped++
        } else {
            Write-KbInfo "Cloning $name (depth=$depth)..."
            # core.protectNTFS=false skips case-colliding files on Windows
            # instead of aborting. Capture stderr as warnings.
            $prev = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            $gitOut = & git -c core.protectNTFS=false clone --depth=$depth --quiet $url $targetDir 2>&1
            $exit = $LASTEXITCODE
            $ErrorActionPreference = $prev
            foreach ($line in $gitOut) {
                if ($line -is [System.Management.Automation.ErrorRecord]) {
                    Write-KbWarn "git: $($line.Exception.Message)"
                } elseif ("$line".Trim()) {
                    Write-KbWarn "git: $line"
                }
            }
            $cloneOk = ($exit -eq 0) -or (Test-Path (Join-Path $targetDir ".git"))
            if ($cloneOk) {
                Write-KbOk "$name cloned -> $category\$name"
                Write-KbToFile "INFO" "Cloned git repo: $name"
                $success++
            } else {
                Write-KbError "Failed to clone $name from $url"
                Write-KbToFile "ERROR" "Failed to clone git repo: $name ($url)"
                $failed++
            }
        }
    }

    Write-KbInfo "Git sources - success: $success, skipped: $skipped, failed: $failed"
}

# ------------------------------------------------------------------------------
# File download sources (wget equivalent)
# ------------------------------------------------------------------------------

function Fetch-WgetSources {
    Write-KbStep "Processing file downloads"

    $count = & yq '.wget | length' $SOURCES_FILE 2>$null
    if (-not $count -or $count -eq "0" -or $count -eq "null") {
        Write-KbWarn "No wget sources defined in sources.yaml"
        return
    }

    $success = 0; $skipped = 0; $failed = 0

    for ($i = 0; $i -lt [int]$count; $i++) {
        $name     = (& yq ".wget[$i].name"            $SOURCES_FILE).Trim()
        $url      = (& yq ".wget[$i].url"             $SOURCES_FILE).Trim()
        $category = (& yq ".wget[$i].category"        $SOURCES_FILE).Trim()
        $extract  = (& yq ".wget[$i].extract // false" $SOURCES_FILE).Trim()

        if (Test-SkipCategory $category) {
            Write-KbSkip "$name (category $category skipped)"
            $skipped++
            continue
        }

        $categoryDir = Join-Path $DOC_PATH $category
        $targetFile  = Join-Path $categoryDir $name
        Ensure-Dir $categoryDir

        # Skip if already downloaded
        if ($Mode -ne "update" -and (Test-Path $targetFile)) {
            Write-KbSkip "$name (already exists)"
            $skipped++
            continue
        }

        # Skip if already extracted (sentinel file written by Invoke-Extract)
        if ($extract -eq "true" -and $Mode -ne "update" -and (Test-Path "$targetFile.done")) {
            Write-KbSkip "$name (already extracted)"
            $skipped++
            continue
        }

        Write-KbInfo "Downloading $name..."
        $exitCode = Invoke-CurlDownload -Url $url -Output $targetFile
        if ($exitCode -eq 0 -and (Test-Path $targetFile)) {
            Write-KbOk "$name -> $category\$name"
            Write-KbToFile "INFO" "Downloaded: $name"

            if ($extract -eq "true") {
                Invoke-Extract -File $targetFile -DestDir $categoryDir
            }
            $success++
        } else {
            Write-KbError "Failed to download $name from $url"
            Write-KbToFile "ERROR" "Failed to download: $name ($url)"
            if (Test-Path $targetFile) { Remove-Item $targetFile -Force }
            $failed++
        }
    }

    Write-KbInfo "File downloads - success: $success, skipped: $skipped, failed: $failed"
}

# ------------------------------------------------------------------------------
# Zeal / Dash docsets
# ------------------------------------------------------------------------------

function Fetch-ZealSources {
    Write-KbStep "Processing Zeal/Dash docsets"

    $count = & yq '.zeal | length' $SOURCES_FILE 2>$null
    if (-not $count -or $count -eq "0" -or $count -eq "null") {
        Write-KbWarn "No zeal sources defined in sources.yaml"
        return
    }

    $success = 0; $skipped = 0; $failed = 0
    # Fall back to 'london' if ZEAL_CDN env var is not set.
    # Valid options: sanfrancisco, london, newyork, tokyo, frankfurt
    $cdn = if ($env:ZEAL_CDN) { $env:ZEAL_CDN } else { 'london' }

    for ($i = 0; $i -lt [int]$count; $i++) {
        $name     = (& yq ".zeal[$i].name"     $SOURCES_FILE).Trim()
        $category = (& yq ".zeal[$i].category" $SOURCES_FILE).Trim()

        if (Test-SkipCategory $category) {
            Write-KbSkip "$name docset (category $category skipped)"
            $skipped++
            continue
        }

        $categoryDir = Join-Path $DOC_PATH $category
        $docsetDir   = Join-Path $categoryDir "$name.docset"
        $tgzFile     = Join-Path $categoryDir "$name.tgz"
        $docsetUrl   = "http://$cdn.kapeli.com/feeds/$name.tgz"
        Ensure-Dir $categoryDir

        if (Test-Path $docsetDir) {
            Write-KbSkip "$name.docset (already installed)"
            $skipped++
            continue
        }

        Write-KbInfo "Downloading $name docset..."
        $exitCode = Invoke-CurlDownload -Url $docsetUrl -Output $tgzFile
        if ($exitCode -eq 0 -and (Test-Path $tgzFile)) {
            # Verify it is actually a tar archive before attempting extraction.
            # A 404 from the CDN returns an HTML page, not a tgz.
            $magic = [System.IO.File]::ReadAllBytes($tgzFile) | Select-Object -First 2
            $isTar = ($magic[0] -eq 0x1f -and $magic[1] -eq 0x8b)  # gzip magic bytes
            if (-not $isTar) {
                Write-KbError "$name docset download was not a valid archive (CDN may have returned an error page)"
                Remove-Item $tgzFile -Force
                $failed++
                continue
            }
            Write-KbInfo "Extracting $name docset..."
            $prev = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            $tarOut = & tar -xzf $tgzFile -C $categoryDir 2>&1
            $tarExit = $LASTEXITCODE
            $ErrorActionPreference = $prev
            foreach ($line in $tarOut) {
                if ("$line".Trim()) { Write-KbWarn "tar: $line" }
            }
            if ($tarExit -eq 0 -or (Test-Path $docsetDir)) {
                # Clean up the tgz whether extraction was clean or partial
                if (Test-Path $tgzFile) { Remove-Item $tgzFile -Force }
                if ($tarExit -eq 0) {
                    Write-KbOk "$name.docset -> $category\"
                } else {
                    # Partial extraction (e.g. symlinks or reserved filenames on Windows)
                    Write-KbWarn "$name.docset extracted with warnings (some files skipped) -> $category\"
                }
                Write-KbToFile "INFO" "Installed docset: $name"
                $success++
            } else {
                Write-KbError "Failed to extract $name docset"
                if (Test-Path $tgzFile) { Remove-Item $tgzFile -Force }
                $failed++
            }
        } else {
            Write-KbError "Failed to download $name docset from $docsetUrl"
            Write-KbToFile "ERROR" "Failed to download docset: $name"
            if (Test-Path $tgzFile) { Remove-Item $tgzFile -Force }
            $failed++
        }
    }

    Write-KbInfo "Docsets - success: $success, skipped: $skipped, failed: $failed"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

Invoke-RequireCommand "yq"
Invoke-RequireCommand "git"
Invoke-RequireCommand "curl"

if (-not (Test-Path $SOURCES_FILE)) {
    Write-KbError "sources.yaml not found at: $SOURCES_FILE"
    exit 1
}

Write-KbStep "Fetch mode: $Mode"
Write-KbInfo "Documentation path: $DOC_PATH"
Write-KbInfo "Sources file: $SOURCES_FILE"

Fetch-GitSources
Fetch-WgetSources
Fetch-ZealSources

Write-KbStep "Fetch complete"