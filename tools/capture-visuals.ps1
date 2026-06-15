param(
    [string]$OutputDir = "visual-tests/screenshots",
    [switch]$Headless
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

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

$Godot = Find-Godot
if (-not $Godot) {
    Write-Host "Godot not found on PATH or in default install locations." -ForegroundColor Red
    exit 1
}

$GodotArgs = @(
    "--path", $ProjectRoot,
    "--script", "res://tools/capture_visual_tests.gd",
    "--",
    "--output-dir=$OutputDir"
)

if ($Headless) {
    $GodotArgs = @("--headless") + $GodotArgs
}

& $Godot @GodotArgs
exit $LASTEXITCODE
