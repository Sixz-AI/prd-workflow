# install.ps1 — prd-workflow Windows installer
#
# Usage:   .\install.ps1 [-Target <project_path>]
# Default: current directory (run from your project root)
#
# Example: .\install.ps1
#          .\install.ps1 -Target C:\Users\you\projects\my-app

param(
    [string]$Target = "."
)

$ErrorActionPreference = "Stop"

$RepoDir  = $PSScriptRoot
$Target   = Resolve-Path $Target
$SkillsDir = Join-Path $Target ".claude\skills"

Write-Host "Installing prd-workflow skills to: $SkillsDir"
Write-Host ""

New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

# ── prd_decomposer ────────────────────────────────────────────────────────────
$decomposerDest = Join-Path $SkillsDir "prd_decomposer"
if (Test-Path $decomposerDest) {
    Write-Host "⚠  prd_decomposer already exists — skipping."
} else {
    Copy-Item -Recurse -Path (Join-Path $RepoDir "prd_decomposer") -Destination $decomposerDest
    Write-Host "✓  prd_decomposer → $decomposerDest"
}

# ── prd_executor ──────────────────────────────────────────────────────────────
$executorDest = Join-Path $SkillsDir "prd_executor"
if (Test-Path $executorDest) {
    Write-Host "⚠  prd_executor already exists — skipping."
} else {
    Copy-Item -Recurse -Path (Join-Path $RepoDir "prd_executor") -Destination $executorDest
    Write-Host "✓  prd_executor → $executorDest"
}

Write-Host ""
Write-Host "Done. Restart Claude Code in $Target to activate the skills."
