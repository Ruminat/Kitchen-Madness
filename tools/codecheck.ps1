# Run before every handoff. Exit non-zero on any failure.
# Usage: .\tools\codecheck.ps1

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$Failed = $false

function Write-Step($Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Find-Godot {
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $cmd = Get-Command godot4 -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $paths = @(
        "$env:LOCALAPPDATA\Programs\Godot\Godot_v4*.exe",
        "$env:ProgramFiles\Godot*\Godot*.exe"
    )
    foreach ($pattern in $paths) {
        $match = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($match) { return $match.FullName }
    }
    return $null
}

Write-Step "Lint (gdlint)"
$Gdlint = Get-Command gdlint -ErrorAction SilentlyContinue
if ($Gdlint) {
    & gdlint scripts/ tests/ 2>&1
    if ($LASTEXITCODE -ne 0) { $Failed = $true }
} else {
    Write-Host "SKIP: gdlint not found (pip install gdtoolkit)" -ForegroundColor Yellow
}

Write-Step "Format check (gdformat)"
$Gdformat = Get-Command gdformat -ErrorAction SilentlyContinue
if ($Gdformat) {
    & gdformat --check scripts/ tests/ 2>&1
    if ($LASTEXITCODE -ne 0) { $Failed = $true }
} else {
    Write-Host "SKIP: gdformat not found (pip install gdtoolkit)" -ForegroundColor Yellow
}

Write-Step "Headless boot smoke"
$Godot = Find-Godot
if ($Godot) {
    & $Godot --headless --path $ProjectRoot --quit-after 1 2>&1
    if ($LASTEXITCODE -ne 0) { $Failed = $true }
} else {
    Write-Host "SKIP: Godot not found on PATH or in default install locations" -ForegroundColor Yellow
}

Write-Step "Unit tests"
if ($Godot -and (Test-Path "addons/gdUnit4/bin/GdUnitCmdTool.gd")) {
    & $Godot --headless --path $ProjectRoot -s addons/gdUnit4/bin/GdUnitCmdTool.gd --addons -a tests/ 2>&1
    if ($LASTEXITCODE -ne 0) { $Failed = $true }
} else {
    Write-Host "SKIP: GdUnit4 not installed or Godot unavailable" -ForegroundColor Yellow
}

Write-Host ""
if ($Failed) {
    Write-Host "codecheck FAILED" -ForegroundColor Red
    exit 1
}

Write-Host "codecheck passed" -ForegroundColor Green
exit 0
