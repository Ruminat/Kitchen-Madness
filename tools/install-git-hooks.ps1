# Install project git hooks into .git/hooks (no git config changes).
# Usage: .\tools\install-git-hooks.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$SourceHook = Join-Path $ProjectRoot ".githooks\pre-commit"
$HooksDir = Join-Path $ProjectRoot ".git\hooks"
$TargetHook = Join-Path $HooksDir "pre-commit"

if (-not (Test-Path $SourceHook)) {
    Write-Error "Missing hook source: $SourceHook"
}

New-Item -ItemType Directory -Force -Path $HooksDir | Out-Null
Copy-Item -Path $SourceHook -Destination $TargetHook -Force

Write-Host "Installed pre-commit hook -> .git/hooks/pre-commit"
Write-Host "On main/master branches, commits will run tools/codecheck."
