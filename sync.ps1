#Requires -Version 5.1
<#
.SYNOPSIS
    Sync the knowledge-base documentation library to an external drive.

.DESCRIPTION
    Uses robocopy (built into Windows) to mirror the library to a USB drive
    or any other destination path.

.PARAMETER Destination
    Target path, e.g. E:\ or D:\backup. A "docs" subfolder will be created.

.PARAMETER DryRun
    Preview what would be synced without making changes.

.PARAMETER Mirror
    Mirror mode: delete files at the destination that no longer exist at the source.
    Equivalent to rsync --delete on Linux/macOS.

.EXAMPLE
    .\sync.ps1 -Destination E:\
    .\sync.ps1 -Destination D:\backup -DryRun
    .\sync.ps1 -Destination E:\ -Mirror
#>

param(
    [Parameter(Mandatory)]
    [string]$Destination,
    [switch]$DryRun,
    [switch]$Mirror
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot

. (Join-Path $RepoDir "scripts\lib.ps1")
. (Join-Path $RepoDir "config\settings.ps1")

$DOC_PATH = $env:DOC_PATH
$DestPath = Join-Path $Destination "docs"

Write-Host ""
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host "|       knowledge-base sync (Windows)     |" -ForegroundColor Cyan
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $DOC_PATH)) {
    Write-KbError "Source not found: $DOC_PATH"
    Write-KbError "Run .\setup.ps1 first"
    exit 1
}

if (-not (Test-Path $Destination)) {
    Write-KbError "Destination not found: $Destination"
    Write-KbError "Make sure the drive is connected and the path exists"
    exit 1
}

Write-KbInfo "Source : $DOC_PATH"
Write-KbInfo "Dest   : $DestPath"

if ($DryRun) { Write-KbWarn "DRY RUN — no changes will be made" }
if ($Mirror) { Write-KbWarn "Mirror mode: files at destination not in source will be deleted" }

# Build robocopy arguments
# /E     — copy subdirectories including empty ones
# /XD    — exclude directories
# /XF    — exclude files
# /NP    — no progress percentage (cleaner output)
# /NFL   — no file list (suppress per-file output for speed)
# /NDL   — no directory list
# /BYTES — show file sizes in bytes

$robocopyArgs = @(
    $DOC_PATH,
    $DestPath,
    "/E",
    "/XD", ".git", "node_modules", "__pycache__",
    "/XF", "*.pyc",
    "/NP"
)

if ($Mirror) {
    $robocopyArgs += "/MIR"
}

if ($DryRun) {
    $robocopyArgs += "/L"  # list only, no copy
}

Write-KbStep "Starting sync..."
robocopy @robocopyArgs

# robocopy exit codes: 0-7 are success/informational; 8+ indicate errors
$rc = $LASTEXITCODE
if ($rc -ge 8) {
    Write-KbError "robocopy reported errors (exit code $rc)"
    exit 1
}

if (-not $DryRun) {
    $destSize = Get-HumanSize $DestPath
    Write-KbSummary "Sync Complete" @(
        "Source : $DOC_PATH"
        "Dest   : $DestPath"
        "Size   : $destSize"
    )
}
