# generate_readme.ps1 — Windows equivalent of generate_readme.sh
#
# Usage: .\generate_readme.ps1 -TargetDir <path> -FeatureName <name>
# Example: .\generate_readme.ps1 -TargetDir "C:\project\docs\login_breakdown" -FeatureName "Login Module"

param(
    [Parameter(Mandatory=$true)][string]$TargetDir,
    [Parameter(Mandatory=$true)][string]$FeatureName
)

$ErrorActionPreference = "Stop"

$ScriptDir    = $PSScriptRoot
$TemplateFile = Join-Path $ScriptDir "..\resources\README_template.md"
$OutputFile   = Join-Path $TargetDir "README.md"

if (-not (Test-Path $TemplateFile)) {
    Write-Error "Template not found: $TemplateFile"
    exit 1
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

(Get-Content $TemplateFile -Raw) -replace '\[Feature Name\]', $FeatureName |
    Set-Content -Path $OutputFile -Encoding UTF8

Write-Host "Successfully generated $OutputFile"
