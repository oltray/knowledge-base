# ==============================================================================
# index.ps1 — Generate a markdown index of what's installed in DOC_PATH
# Writes to DOC_PATH\00-index\README.md and DOC_PATH\00-index\status.md
# ==============================================================================

$ScriptDir = $PSScriptRoot
$RepoDir   = Split-Path $ScriptDir -Parent

. (Join-Path $ScriptDir "lib.ps1")
. (Join-Path $RepoDir "config\settings.ps1")

$DOC_PATH     = $env:DOC_PATH
$SOURCES_FILE = $script:KB_SOURCES_FILE
$INDEX_DIR    = Join-Path $DOC_PATH "00-index"
$README_FILE  = Join-Path $INDEX_DIR "README.md"
$STATUS_FILE  = Join-Path $INDEX_DIR "status.md"

function Get-CategoryName {
    param([string]$Name)
    switch ($Name) {
        "00-index"       { return "Index" }
        "01-languages"   { return "Programming Languages" }
        "02-web"         { return "Web Technologies" }
        "03-systems"     { return "Operating Systems & Systems Programming" }
        "04-networking"  { return "Networking" }
        "05-security"    { return "Security" }
        "06-databases"   { return "Databases" }
        "07-devops"      { return "DevOps & Infrastructure" }
        "08-tools"       { return "Development Tools" }
        "09-algorithms"  { return "Algorithms & Data Structures" }
        "10-architecture"{ return "Software Architecture" }
        "11-standards"   { return "Standards Documents" }
        "99-extras"      { return "Books, Papers & Extras" }
        default          { return $Name }
    }
}

function New-KbReadme {
    Write-KbStep "Generating index: $README_FILE"
    New-Item -ItemType Directory -Path $INDEX_DIR -Force | Out-Null

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $lines = [System.Collections.Generic.List[string]]::new()

    $lines.Add("# Knowledge Base — Documentation Library")
    $lines.Add("")
    $lines.Add("> Generated: $timestamp")
    $lines.Add("> Location: ``$DOC_PATH``")
    $lines.Add("")
    $lines.Add("---")
    $lines.Add("")
    $lines.Add("## Table of Contents")
    $lines.Add("")

    # TOC
    $categories = Get-ChildItem -Path $DOC_PATH -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match '^\d{2}-' } |
        Sort-Object Name
    foreach ($cat in $categories) {
        if ($cat.Name -eq "00-index") { continue }
        $displayName = Get-CategoryName $cat.Name
        $anchor = $displayName.ToLower() -replace '[^a-z0-9\s-]','' -replace '\s+','-'
        $lines.Add("- [$displayName](#$anchor)")
    }

    $lines.Add("")
    $lines.Add("---")
    $lines.Add("")

    # Category sections
    foreach ($cat in $categories) {
        if ($cat.Name -eq "00-index") { continue }
        $displayName = Get-CategoryName $cat.Name
        $catSize     = Get-HumanSize $cat.FullName

        $lines.Add("## $displayName")
        $lines.Add("")
        $lines.Add("_Path: ``$($cat.FullName)`` | Size: $catSize_")
        $lines.Add("")

        $hasContent = $false

        foreach ($subdir in (Get-ChildItem -Path $cat.FullName -Directory -ErrorAction SilentlyContinue | Sort-Object Name)) {
            $subSize = Get-HumanSize $subdir.FullName
            $lines.Add("- ``$($subdir.Name)\`` — $subSize")
            $hasContent = $true
        }

        foreach ($file in (Get-ChildItem -Path $cat.FullName -File -ErrorAction SilentlyContinue | Sort-Object Name)) {
            $fileSize = Get-HumanSize $file.FullName
            $lines.Add("- ``$($file.Name)`` — $fileSize")
            $hasContent = $true
        }

        if (-not $hasContent) {
            $lines.Add("_Empty — run ``.\setup.ps1`` or ``.\update.ps1`` to populate_")
        }

        $lines.Add("")
    }

    $lines.Add("---")
    $lines.Add("")
    $lines.Add("## Total Library Size")
    $lines.Add("")
    $totalSize = Get-HumanSize $DOC_PATH
    $lines.Add("**$totalSize** stored in ``$DOC_PATH``")
    $lines.Add("")
    $lines.Add("---")
    $lines.Add("")
    $lines.Add("_To regenerate this index: ``.\scripts\index.ps1``_")
    $lines.Add("_To update all sources: ``.\update.ps1``_")

    $lines | Out-File -FilePath $README_FILE -Encoding UTF8
    Write-KbOk "Index written -> $README_FILE"
}

function New-KbStatus {
    Write-KbStep "Generating status: $STATUS_FILE"

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $lines = [System.Collections.Generic.List[string]]::new()

    $lines.Add("# Source Status")
    $lines.Add("")
    $lines.Add("> Generated: $timestamp")
    $lines.Add("")
    $lines.Add("| Source | Type | Category | Status | Size |")
    $lines.Add("|--------|------|----------|--------|------|")

    # Git sources
    $gitCount = & yq '.git | length' $SOURCES_FILE 2>$null
    if ($gitCount -and $gitCount -ne "null" -and [int]$gitCount -gt 0) {
        for ($i = 0; $i -lt [int]$gitCount; $i++) {
            $name     = (& yq ".git[$i].name"     $SOURCES_FILE).Trim()
            $category = (& yq ".git[$i].category" $SOURCES_FILE).Trim()
            $target   = Join-Path $DOC_PATH "$category\$name"
            if (Test-Path (Join-Path $target ".git")) {
                $status = "Installed"
                $size   = Get-HumanSize $target
            } else {
                $status = "Not fetched"
                $size   = "--"
            }
            $lines.Add("| $name | git | $category | $status | $size |")
        }
    }

    # Wget sources
    $wgetCount = & yq '.wget | length' $SOURCES_FILE 2>$null
    if ($wgetCount -and $wgetCount -ne "null" -and [int]$wgetCount -gt 0) {
        for ($i = 0; $i -lt [int]$wgetCount; $i++) {
            $name     = (& yq ".wget[$i].name"            $SOURCES_FILE).Trim()
            $category = (& yq ".wget[$i].category"        $SOURCES_FILE).Trim()
            $extract  = (& yq ".wget[$i].extract // false" $SOURCES_FILE).Trim()
            $catDir   = Join-Path $DOC_PATH $category

            if ($extract -eq "true") {
                $baseName = [System.IO.Path]::GetFileNameWithoutExtension(
                    [System.IO.Path]::GetFileNameWithoutExtension($name)
                )
                if (Test-Path (Join-Path $catDir $baseName)) {
                    $status = "Installed"
                    $size   = Get-HumanSize (Join-Path $catDir $baseName)
                } elseif (Test-Path (Join-Path $catDir $name)) {
                    $status = "Downloaded"
                    $size   = Get-HumanSize (Join-Path $catDir $name)
                } else {
                    $status = "Not fetched"
                    $size   = "--"
                }
            } else {
                if (Test-Path (Join-Path $catDir $name)) {
                    $status = "Downloaded"
                    $size   = Get-HumanSize (Join-Path $catDir $name)
                } else {
                    $status = "Not fetched"
                    $size   = "--"
                }
            }
            $lines.Add("| $name | wget | $category | $status | $size |")
        }
    }

    # Zeal sources
    $zealCount = & yq '.zeal | length' $SOURCES_FILE 2>$null
    if ($zealCount -and $zealCount -ne "null" -and [int]$zealCount -gt 0) {
        for ($i = 0; $i -lt [int]$zealCount; $i++) {
            $name      = (& yq ".zeal[$i].name"     $SOURCES_FILE).Trim()
            $category  = (& yq ".zeal[$i].category" $SOURCES_FILE).Trim()
            $docsetDir = Join-Path $DOC_PATH "$category\$name.docset"
            if (Test-Path $docsetDir) {
                $status = "Installed"
                $size   = Get-HumanSize $docsetDir
            } else {
                $status = "Not fetched"
                $size   = "--"
            }
            $lines.Add("| $name.docset | zeal | $category | $status | $size |")
        }
    }

    $lines | Out-File -FilePath $STATUS_FILE -Encoding UTF8
    Write-KbOk "Status written -> $STATUS_FILE"
}

function New-CurriculumStatus {
    $vaultPath = $env:OBSIDIAN_VAULT_PATH
    if (-not (Test-Path $vaultPath)) { return }

    Write-KbStep "Generating curriculum status: $vaultPath\status.md"

    $out             = Join-Path $vaultPath "status.md"
    $repoCurriculum  = Join-Path $RepoDir "curriculum\tracks"
    $docPath         = $env:DOC_PATH
    $timestamp       = Get-Date -Format 'yyyy-MM-dd HH:mm'

    function Get-ModuleStatus([string]$TrackDir) {
        $trackPath = Join-Path $repoCurriculum $TrackDir
        $n = 0
        if (Test-Path $trackPath) {
            $n = (Get-ChildItem -Path $trackPath -Filter "*.md" -File -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -ne "index.md" }).Count
        }
        if ($n -gt 0) { return "✅ $n modules" } else { return "🔜 Planned" }
    }

    function Get-DocStatus([string]$RelFolder) {
        $path = Join-Path $docPath $RelFolder
        if ((Test-Path $path) -and (Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue).Count -gt 0) {
            return "✅ $RelFolder"
        } else {
            return "⬜ $RelFolder — run ``.\update.ps1``"
        }
    }

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# Library Status")
    $lines.Add("")
    $lines.Add("_Generated: $timestamp_")
    $lines.Add("")
    $lines.Add("## Curriculum Readiness")
    $lines.Add("")
    $lines.Add("| Track | Modules | Docs Installed |")
    $lines.Add("|---|---|---|")
    $lines.Add("| [00 — Foundations](curriculum/tracks/00-foundations/index.md) | $(Get-ModuleStatus '00-foundations') | — (uses system docs) |")
    $lines.Add("| [01 — Python](curriculum/tracks/01-languages/python/index.md) | $(Get-ModuleStatus '01-languages\python') | $(Get-DocStatus '01-languages\python') |")
    $lines.Add("| [02 — Web](curriculum/tracks/02-web/index.md) | $(Get-ModuleStatus '02-web') | $(Get-DocStatus '02-web\html-css') |")
    $lines.Add("| [01 — JavaScript](curriculum/tracks/01-languages/javascript/index.md) | $(Get-ModuleStatus '01-languages\javascript') | $(Get-DocStatus '01-languages\javascript') |")
    $lines.Add("| [01 — Rust](curriculum/tracks/01-languages/rust/index.md) | $(Get-ModuleStatus '01-languages\rust') | $(Get-DocStatus '01-languages\rust') |")
    $lines.Add("| [01 — C/C++](curriculum/tracks/01-languages/c-cpp/index.md) | $(Get-ModuleStatus '01-languages\c-cpp') | $(Get-DocStatus '01-languages\c-cpp') |")
    $lines.Add("| [03 — Systems](curriculum/tracks/03-systems/index.md) | $(Get-ModuleStatus '03-systems') | $(Get-DocStatus '03-systems\linux') |")
    $lines.Add("| [04 — Networking](curriculum/tracks/04-networking/index.md) | $(Get-ModuleStatus '04-networking') | $(Get-DocStatus '04-networking\protocols') |")
    $lines.Add("| [05 — Security](curriculum/tracks/05-security/index.md) | $(Get-ModuleStatus '05-security') | $(Get-DocStatus '05-security\owasp') |")
    $lines.Add("| [06 — Databases](curriculum/tracks/06-databases/index.md) | $(Get-ModuleStatus '06-databases') | $(Get-DocStatus '06-databases\sql') |")
    $lines.Add("| [07 — DevOps](curriculum/tracks/07-devops/index.md) | $(Get-ModuleStatus '07-devops') | $(Get-DocStatus '07-devops\docker') |")
    $lines.Add("")
    $lines.Add("## Full Source Status")
    $lines.Add("")
    $lines.Add("See [$docPath\00-index\status.md]($docPath\00-index\status.md) for the complete")
    $lines.Add("list of all documentation sources and their installation state.")
    $lines.Add("")
    $lines.Add("---")
    $lines.Add("_Update docs: ``.\update.ps1`` · Get new curriculum modules: ``git pull`` in the repo_")

    $lines | Set-Content -Path $out -Encoding UTF8
    Write-KbOk "Curriculum status written -> $out"
}

function Update-VaultHome {
    $vaultPath = $env:OBSIDIAN_VAULT_PATH
    if (-not (Test-Path $vaultPath)) { return }
    $home = Join-Path $vaultPath "Home.md"
    if (-not (Test-Path $home)) { return }
    $content = Get-Content $home -Raw
    if ($content -match "## Start Learning") {
        Write-KbSkip "Home.md already has Start Learning section"
        return
    }
    $patch = "`n---`n`n## Start Learning`n`n→ [[curriculum/overview|Curriculum Overview]] — Where to start and how to use these docs`n"
    Add-Content -Path $home -Value $patch -Encoding UTF8
    Write-KbOk "Home.md patched with Start Learning section"
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

Invoke-RequireCommand "yq"

if (-not (Test-Path $DOC_PATH)) {
    Write-KbError "DOC_PATH does not exist: $DOC_PATH"
    Write-KbError "Run .\setup.ps1 first"
    exit 1
}

New-KbReadme
New-KbStatus
New-CurriculumStatus
Update-VaultHome
