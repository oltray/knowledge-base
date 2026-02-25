#Requires -Version 5.1
<#
.SYNOPSIS
    Verify all relative markdown links in the curriculum directory.

.DESCRIPTION
    Scans all *.md files under $OBSIDIAN_VAULT_PATH\curriculum\, extracts
    relative markdown links, resolves them relative to the containing file's
    directory, and checks that each target exists on disk.

    Skips: http/https URLs, Obsidian [[wiki-links]], and #anchor-only fragments.

.EXAMPLE
    .\scripts\check-curriculum-links.ps1

.OUTPUTS
    Prints broken links to stdout. Exits with code 1 if any broken links found.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoDir = Split-Path $PSScriptRoot -Parent

. (Join-Path $RepoDir "config\settings.ps1")

$CurriculumDir = Join-Path $env:OBSIDIAN_VAULT_PATH "curriculum"

if (-not (Test-Path $CurriculumDir)) {
    Write-Error "Curriculum directory not found: $CurriculumDir`nRun .\setup.ps1 first."
    exit 1
}

$broken  = 0
$checked = 0

# Match ](path) markdown links — capture the path inside the parens
$linkPattern = [regex]'\]\(([^)]+)\)'

Get-ChildItem -Path $CurriculumDir -Recurse -Filter "*.md" | ForEach-Object {
    $mdFile  = $_.FullName
    $fileDir = $_.DirectoryName
    $content = Get-Content $mdFile -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return }

    $matches = $linkPattern.Matches($content)
    foreach ($m in $matches) {
        $linkPath = $m.Groups[1].Value

        # Strip fragment (#section)
        if ($linkPath -match '^([^#]*)#') {
            $linkPath = $Matches[1]
        }

        # Skip empty after stripping fragment
        if ([string]::IsNullOrWhiteSpace($linkPath)) { continue }

        # Skip external URLs
        if ($linkPath -match '^https?://') { continue }

        # Skip Obsidian wiki-links (shouldn't appear in () links, but guard anyway)
        if ($linkPath -match '^\[\[') { continue }

        # Resolve relative to the containing file's directory
        # Normalize forward slashes to backslashes for Windows path resolution
        $linkPathNorm = $linkPath -replace '/', '\'

        try {
            $resolved = [System.IO.Path]::GetFullPath(
                [System.IO.Path]::Combine($fileDir, $linkPathNorm)
            )
        } catch {
            continue
        }

        $checked++

        if (-not (Test-Path $resolved)) {
            Write-Host "BROKEN: $mdFile"
            Write-Host "        link: $linkPath"
            Write-Host "        resolved: $resolved"
            $broken++
        }
    }
}

Write-Host ""
Write-Host "Link check complete: $checked links checked"

if ($broken -gt 0) {
    Write-Error "FAILED: $broken broken link(s) found"
    exit 1
} else {
    Write-Host "PASSED: all links valid"
}
