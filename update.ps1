#Requires -Version 5.1
<#
.SYNOPSIS
    Update all documentation sources in the knowledge-base library.

.PARAMETER GitOnly
    Only git pull existing repositories (fast, skips file downloads).

.PARAMETER NoIndex
    Skip regenerating the index after updating.

.EXAMPLE
    .\update.ps1
    .\update.ps1 -GitOnly
    .\update.ps1 -NoIndex
#>

param(
    [switch]$GitOnly,
    [switch]$NoIndex
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoDir = $PSScriptRoot

. (Join-Path $RepoDir "scripts\lib.ps1")
. (Join-Path $RepoDir "config\settings.ps1")

$DOC_PATH            = $env:DOC_PATH
$OBSIDIAN_VAULT_PATH  = $env:OBSIDIAN_VAULT_PATH

function Sync-Curriculum {
    $curriculumSrc  = Join-Path $RepoDir "curriculum"
    $curriculumDest = Join-Path $OBSIDIAN_VAULT_PATH "curriculum"

    if (Test-Path $curriculumDest) {
        $item = Get-Item $curriculumDest -ErrorAction SilentlyContinue
        if ($item -and $item.LinkType -eq "Junction") {
            Write-KbInfo "Curriculum junction up to date via git pull"
            return
        }

        # Plain directory — re-sync
        Write-KbStep "Syncing curriculum directory (plain copy, not junction)"
        Copy-Item -Path (Join-Path $curriculumSrc "*") -Destination $curriculumDest -Recurse -Force
        Write-KbOk "Curriculum synced"
        return
    }

    # Missing entirely — recreate
    Write-KbStep "Curriculum missing from vault — recreating"
    $vaultPath = $OBSIDIAN_VAULT_PATH
    if (Test-Path $vaultPath) {
        try {
            New-Item -ItemType Junction -Path $curriculumDest -Target $curriculumSrc | Out-Null
            Write-KbOk "Curriculum junction created: $curriculumDest -> $curriculumSrc"
        } catch {
            Copy-Item -Path $curriculumSrc -Destination $curriculumDest -Recurse -Force
            Write-KbOk "Curriculum copied to $curriculumDest"
        }
    } else {
        Write-KbWarn "Obsidian vault not found at $vaultPath — skipping curriculum sync"
    }
}

Write-Host ""
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host "|      knowledge-base update (Windows)    |" -ForegroundColor Cyan
Write-Host "+==========================================+" -ForegroundColor Cyan
Write-Host ""

Invoke-RequireCommand "yq"
Invoke-RequireCommand "git"
Invoke-RequireCommand "curl"

if (-not (Test-Path $DOC_PATH)) {
    Write-KbError "DOC_PATH not found: $DOC_PATH"
    Write-KbError "Run .\setup.ps1 first to initialize the library"
    exit 1
}

Write-KbToFile "INFO" "=== Update started ==="

$fetchMode = if ($GitOnly) { "update" } else { "update" }
& (Join-Path $RepoDir "scripts\fetch.ps1") -Mode $fetchMode

Sync-Curriculum

if (-not $NoIndex) {
    & (Join-Path $RepoDir "scripts\index.ps1")
}

Write-KbToFile "INFO" "=== Update complete ==="

Write-KbSummary "Update Complete" @(
    "Library: $DOC_PATH"
    "Index  : $DOC_PATH\00-index\README.md"
    "Log    : $($env:KB_LOG_FILE)"
)
