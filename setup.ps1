#Requires -Version 5.1
<#
.SYNOPSIS
    Bootstrap the knowledge-base documentation library on Windows.

.DESCRIPTION
    Installs dependencies via winget, creates the documentation directory
    structure, sets up the Obsidian vault, and fetches all sources defined
    in config\sources.yaml.

.PARAMETER DryRun
    Show what would happen without making any changes.

.PARAMETER SkipFetch
    Create directory structure only; skip downloading documentation.

.PARAMETER DocPath
    Override the default documentation path ($HOME\docs).

.EXAMPLE
    .\setup.ps1
    .\setup.ps1 -DryRun
    .\setup.ps1 -SkipFetch
    .\setup.ps1 -DocPath "D:\docs"

.NOTES
    Requirements: Windows 10 21H1+ or Windows 11 (winget must be available).
    Run once to set execution policy if needed:
        Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#>

param(
    [switch]$DryRun,
    [switch]$SkipFetch,
    [string]$DocPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot

. (Join-Path $RepoDir "scripts\lib.ps1")
. (Join-Path $RepoDir "config\settings.ps1")

# Allow DocPath parameter to override the environment variable
if ($DocPath) { $env:DOC_PATH = $DocPath }

$DOC_PATH           = $env:DOC_PATH
$OBSIDIAN_VAULT_PATH = $env:OBSIDIAN_VAULT_PATH
$LOG_FILE           = $env:KB_LOG_FILE

# ==============================================================================
# 1. Install dependencies
# ==============================================================================

function Install-Deps {
    Write-KbStep "Installing dependencies"

    # Check winget
    if (-not (Test-KbCommand "winget")) {
        Write-KbError "winget not found."
        Write-KbError "Install the App Installer from the Microsoft Store, then re-run setup.ps1"
        Write-KbError "https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1"
        exit 1
    }

    if ($DryRun) {
        Write-KbInfo "[dry-run] Would install via winget: git, yq"
        Write-KbInfo "[dry-run] curl.exe and tar.exe are built into Windows 10+"
        return
    }

    # git
    if (-not (Test-KbCommand "git")) {
        Write-KbInfo "Installing Git for Windows..."
        winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
    } else {
        Write-KbInfo "git already installed: $(git --version)"
    }

    # yq (YAML processor — same tool used by Linux/macOS scripts)
    if (-not (Test-KbCommand "yq")) {
        Write-KbInfo "Installing yq..."
        winget install --id MikeFarah.yq -e --source winget --accept-package-agreements --accept-source-agreements
        # Refresh PATH so yq is available in this session
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("PATH","User")
    } else {
        Write-KbInfo "yq already installed: $(yq --version)"
    }

    # curl.exe is built into Windows 10+; verify it
    if (-not (Test-KbCommand "curl")) {
        Write-KbError "curl.exe not found. It is built into Windows 10 1803+."
        Write-KbError "Please update Windows or install curl manually."
        exit 1
    }

    # tar.exe is built into Windows 10 1803+; verify it
    if (-not (Test-KbCommand "tar")) {
        Write-KbError "tar.exe not found. It is built into Windows 10 1803+."
        Write-KbError "Please update Windows."
        exit 1
    }

    # Verify critical tools are now available
    Invoke-RequireCommand "git"
    Invoke-RequireCommand "yq"

    Write-KbOk "Dependencies ready"
}

# ==============================================================================
# 2. Create directory structure
# ==============================================================================

function New-DirectoryStructure {
    Write-KbStep "Creating documentation directory structure"
    Write-KbInfo "Location: $DOC_PATH"

    $dirs = @(
        "00-index"
        "01-languages\python"
        "01-languages\javascript"
        "01-languages\c-cpp"
        "01-languages\rust"
        "01-languages\go"
        "01-languages\java"
        "02-web\html-css"
        "02-web\frontend-frameworks"
        "02-web\backend"
        "03-systems\linux"
        "03-systems\windows"
        "03-systems\unix"
        "03-systems\embedded"
        "04-networking\protocols"
        "04-networking\rfcs"
        "04-networking\tools"
        "05-security\owasp"
        "05-security\nist"
        "05-security\cryptography"
        "05-security\pentesting"
        "06-databases\sql"
        "06-databases\nosql"
        "06-databases\theory"
        "07-devops\docker"
        "07-devops\kubernetes"
        "07-devops\ci-cd"
        "07-devops\cloud"
        "08-tools\git"
        "08-tools\editors"
        "08-tools\build-systems"
        "09-algorithms\references"
        "10-architecture\patterns"
        "11-standards\iso"
        "11-standards\ieee"
        "11-standards\w3c"
        "99-extras\books"
        "99-extras\papers"
        "99-extras\cheatsheets"
    )

    if ($DryRun) {
        Write-KbInfo "[dry-run] Would create $($dirs.Count) directories under $DOC_PATH"
        foreach ($d in $dirs) { Write-Host "  $DOC_PATH\$d" }
        return
    }

    foreach ($d in $dirs) {
        New-Item -ItemType Directory -Path (Join-Path $DOC_PATH $d) -Force | Out-Null
    }

    Write-KbOk "Created $($dirs.Count) directories under $DOC_PATH"
}

# ==============================================================================
# 3. Initialize log file
# ==============================================================================

function Initialize-Log {
    if ($DryRun) { return }

    $logDir = Split-Path $LOG_FILE
    if ($logDir) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    if (-not (Test-Path $LOG_FILE)) { New-Item -ItemType File -Path $LOG_FILE -Force | Out-Null }
    Write-KbToFile "INFO" "=== knowledge-base setup started ==="
    Write-KbToFile "INFO" "DOC_PATH: $DOC_PATH"
    Write-KbToFile "INFO" "REPO_DIR: $RepoDir"
}

# ==============================================================================
# 4. Set up Obsidian vault
# ==============================================================================

function Initialize-ObsidianVault {
    Write-KbStep "Setting up Obsidian vault"

    $vaultSrc  = Join-Path $RepoDir "obsidian"
    $vaultDest = $OBSIDIAN_VAULT_PATH

    if ($DryRun) {
        Write-KbInfo "[dry-run] Would copy Obsidian vault from $vaultSrc -> $vaultDest"
        return
    }

    if (Test-Path $vaultDest) {
        Write-KbSkip "Obsidian vault already exists at $vaultDest"
        return
    }

    Copy-Item -Path $vaultSrc -Destination $vaultDest -Recurse -Force

    # Replace path placeholder in Home.md
    $homeMd = Join-Path $vaultDest "Home.md"
    if (Test-Path $homeMd) {
        (Get-Content $homeMd) -replace 'DOC_PATH_PLACEHOLDER', $DOC_PATH |
            Set-Content $homeMd -Encoding UTF8
    }

    Write-KbOk "Obsidian vault ready -> $vaultDest"
    Write-KbInfo "Open Obsidian -> Open vault as folder -> Select: $vaultDest"
}

# ==============================================================================
# 5. Fetch all documentation
# ==============================================================================

function Invoke-FetchDocs {
    if ($SkipFetch) {
        Write-KbWarn "Skipping documentation fetch (-SkipFetch)"
        return
    }

    if ($DryRun) {
        Write-KbInfo "[dry-run] Would run: .\scripts\fetch.ps1 install"
        return
    }

    & (Join-Path $RepoDir "scripts\fetch.ps1") -Mode install
}

# ==============================================================================
# 6. Generate index
# ==============================================================================

function Invoke-GenerateIndex {
    if ($DryRun) {
        Write-KbInfo "[dry-run] Would run: .\scripts\index.ps1"
        return
    }

    & (Join-Path $RepoDir "scripts\index.ps1")
}

# ==============================================================================
# Main
# ==============================================================================

Write-Host ""
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host "|       knowledge-base setup (Windows)    |" -ForegroundColor Cyan
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) { Write-KbWarn "DRY RUN MODE — no changes will be made" }

Install-Deps
New-DirectoryStructure
Initialize-Log
Initialize-ObsidianVault
Invoke-FetchDocs
Invoke-GenerateIndex

Write-KbSummary "Setup Complete" @(
    "Docs location : $DOC_PATH"
    "Obsidian vault: $OBSIDIAN_VAULT_PATH"
    "Index file    : $DOC_PATH\00-index\README.md"
    "Status file   : $DOC_PATH\00-index\status.md"
    "Log file      : $LOG_FILE"
    ""
    "Next steps:"
    "  Update docs  : .\update.ps1"
    "  Sync to USB  : .\sync.ps1 E:\docs"
)

Write-KbToFile "INFO" "=== knowledge-base setup complete ==="
