# mdbrain installer — thin wrapper over lib/install.js (v0.3+)
#
# If you cloned the repo: this runs the Node installer directly.
# If you have npm: prefer `npx mdbrain install` or `npm i -g mdbrain` instead.
#
# Usage:
#   powershell -File install.ps1                           # default coexist mode
#   powershell -File install.ps1 -Mode fresh               # empty project
#   powershell -File install.ps1 -Mode merge               # append Protocols section
#   powershell -File install.ps1 -Force                    # overwrite existing
#   powershell -File install.ps1 -DryRun                   # simulate
#   powershell -File install.ps1 -ProjectDir "C:\path"     # target another folder
#
# Note: on Windows you may need: powershell -ExecutionPolicy Bypass -File install.ps1

param(
    [string]$ProjectDir = (Get-Location).Path,
    [ValidateSet("coexist", "fresh", "merge")]
    [string]$Mode = "coexist",
    [switch]$Force = $false,
    [switch]$DryRun = $false
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: node not found." -ForegroundColor Red
    Write-Host "mdbrain requires Node.js 20+ (already bundled with Claude Code)."
    Write-Host "Install from https://nodejs.org/"
    exit 1
}

# Build argument list for the Node CLI
$nodeArgs = @("$ScriptDir\bin\mdbrain.js", "install", $ProjectDir, "--mode", $Mode)
if ($Force)  { $nodeArgs += "--force" }
if ($DryRun) { $nodeArgs += "--dry-run" }

& node @nodeArgs
exit $LASTEXITCODE
