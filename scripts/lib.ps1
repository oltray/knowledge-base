# ==============================================================================
# lib.ps1 — Shared utilities for knowledge-base PowerShell scripts
# ==============================================================================

function Write-KbInfo  { param([string]$msg) Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-KbOk    { param([string]$msg) Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-KbWarn  { param([string]$msg) Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-KbError { param([string]$msg) Write-Host "[ERROR] $msg" -ForegroundColor Red -BackgroundColor Black }
function Write-KbStep  { param([string]$msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-KbSkip  { param([string]$msg) Write-Host "[SKIP]  $msg" -ForegroundColor DarkYellow }

function Write-KbToFile {
    param([string]$Level, [string]$Message)
    $logFile = $env:KB_LOG_FILE
    if ($logFile) {
        $dir = Split-Path $logFile
        if ($dir -and (Test-Path $dir)) {
            $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            "[$timestamp] [$Level] $Message" | Out-File -FilePath $logFile -Append -Encoding UTF8
        }
    }
}

function Test-KbCommand {
    param([string]$Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-RequireCommand {
    param([string]$Name)
    if (-not (Test-KbCommand $Name)) {
        Write-KbError "Required command not found: $Name"
        Write-KbError "Please install it and re-run setup.ps1"
        exit 1
    }
}

function Test-SkipCategory {
    param([string]$Category)
    $skip = $env:SKIP_CATEGORIES
    if (-not $skip) { return $false }
    foreach ($s in ($skip -split '\s+')) {
        if ($s -and $Category.StartsWith($s)) { return $true }
    }
    return $false
}

function Get-HumanSize {
    param([string]$Path)
    if (Test-Path $Path -PathType Container) {
        $bytes = (Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue $Path |
                  Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    } elseif (Test-Path $Path -PathType Leaf) {
        $bytes = (Get-Item $Path -ErrorAction SilentlyContinue).Length
    } else {
        return "0 B"
    }
    if (-not $bytes -or $bytes -eq 0) { return "0 B" }
    if ($bytes -ge 1GB) { return "{0:F1} GB" -f ($bytes / 1GB) }
    if ($bytes -ge 1MB) { return "{0:F1} MB" -f ($bytes / 1MB) }
    if ($bytes -ge 1KB) { return "{0:F1} KB" -f ($bytes / 1KB) }
    return "$bytes B"
}

function Write-KbSummary {
    param([string]$Title, [string[]]$Lines)
    $border = "+------------------------------------------+"
    Write-Host ""
    Write-Host $border -ForegroundColor Cyan
    Write-Host "| $Title" -ForegroundColor Cyan
    Write-Host $border -ForegroundColor Cyan
    foreach ($line in $Lines) {
        Write-Host "|  $line" -ForegroundColor Cyan
    }
    Write-Host $border -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-Extract {
    param([string]$File, [string]$DestDir)
    Write-KbInfo "Extracting $(Split-Path $File -Leaf)..."
    switch -Regex ($File) {
        '\.zip$' {
            Expand-Archive -Path $File -DestinationPath $DestDir -Force
            Remove-Item $File -Force
        }
        '\.(tar\.gz|tgz)$' {
            & tar -xzf $File -C $DestDir 2>&1
            if ($LASTEXITCODE -eq 0) { Remove-Item $File -Force }
            else { Write-KbWarn "tar extraction had non-zero exit code for $File" }
        }
        '\.tar\.bz2$' {
            & tar -xjf $File -C $DestDir 2>&1
            if ($LASTEXITCODE -eq 0) { Remove-Item $File -Force }
            else { Write-KbWarn "tar extraction had non-zero exit code for $File" }
        }
        default {
            Write-KbWarn "Unknown archive format, skipping extraction: $(Split-Path $File -Leaf)"
        }
    }
}
