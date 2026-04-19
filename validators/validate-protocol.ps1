# mdbrain — protocol validator (PowerShell)
#
# Verifies a project has mdbrain correctly installed and wired.
# Run from the project root after `powershell -File install.ps1`.
#
# Usage:
#   powershell -File .claude\validators\validate-protocol.ps1
#   powershell -File C:\path\to\mdbrain\validators\validate-protocol.ps1

param(
    [string]$ProjectDir = (Get-Location).Path
)

Set-Location $ProjectDir

$script:Pass = 0
$script:Fail = 0
$script:Warn = 0

function Section { param([string]$Name) Write-Host ""; Write-Host "=== $Name ===" }
function Pass  { param([string]$Msg) Write-Host "  [PASS] $Msg" -ForegroundColor Green;  $script:Pass++ }
function Fail  { param([string]$Msg) Write-Host "  [FAIL] $Msg" -ForegroundColor Red;    $script:Fail++ }
function Warn  { param([string]$Msg) Write-Host "  [WARN] $Msg" -ForegroundColor Yellow; $script:Warn++ }

# -------------------- Core protocol files --------------------

Section "Core protocol files"
foreach ($f in @("BRAIN.md", "CRAFT.md", "PERF.md", "CLAUDE.md")) {
    if (Test-Path $f) { Pass "$f present" } else { Fail "$f missing" }
}

# -------------------- Safety Net — ignore files --------------------

Section "Safety Net — ignore files"
foreach ($f in @(".craftignore", ".perfignore")) {
    if (Test-Path $f) { Pass "$f present" } else { Warn "$f missing (protection reduced)" }
}

# -------------------- .claude/ directory --------------------

Section ".claude/ directory"
if (Test-Path ".claude") { Pass ".claude/ directory exists" } else { Fail ".claude/ directory missing — reinstall" }

# -------------------- Subagents --------------------

Section "Subagents (.claude/agents/)"
foreach ($agent in @("brain-router", "craft-specialist", "perf-specialist")) {
    $f = ".claude/agents/$agent.md"
    if (Test-Path $f) {
        if (Select-String -Path $f -Pattern "^name: $agent$" -Quiet) {
            Pass "$agent subagent registered"
        } else {
            Warn "$agent exists but frontmatter 'name:' mismatch"
        }
    } else {
        Fail "$agent subagent missing: $f"
    }
}

# -------------------- Slash commands --------------------

Section "Slash commands (.claude/commands/)"
foreach ($cmd in @("brain-scan", "craft-audit", "perf-audit")) {
    $f = ".claude/commands/$cmd.md"
    if (Test-Path $f) { Pass "/$cmd command registered" } else { Fail "/$cmd command missing" }
}

# -------------------- Path-scoped rules --------------------

Section "Path-scoped rules (.claude/rules/)"
foreach ($rule in @("craft-rules", "perf-rules")) {
    $f = ".claude/rules/$rule.md"
    if (Test-Path $f) {
        if (Select-String -Path $f -Pattern "^paths:" -Quiet) {
            Pass "$rule has paths: frontmatter"
        } else {
            Warn "$rule exists but no paths: frontmatter (won't auto-scope)"
        }
    } else {
        Fail "$rule missing: $f"
    }
}

# -------------------- Hook --------------------

Section "Hook (.claude/hooks/safety-net.ps1)"
$Hook = ".claude/hooks/safety-net.ps1"
if (Test-Path $Hook) {
    Pass "hook file exists"

    # Test invocation
    try {
        $testInput = '{"tool_name":"Edit","tool_input":{"file_path":"legacy/test.ts"}}'
        $testOut = $testInput | powershell -File $Hook 2>&1 | Out-String
        if ($testOut -match "permissionDecision") {
            Pass "hook executes and returns JSON decision"
        } else {
            Fail "hook did not return valid JSON: $testOut"
        }
    } catch {
        Fail "hook invocation error: $_"
    }
} else {
    Fail "hook missing: $Hook"
}

# -------------------- Settings --------------------

Section "Settings (.claude/settings.json)"
$Settings = ".claude/settings.json"
if (Test-Path $Settings) {
    Pass "settings.json exists"
    try {
        $cfg = Get-Content $Settings -Raw | ConvertFrom-Json
        if ($cfg.hooks.PreToolUse) {
            Pass "PreToolUse hook wired in settings"
        } else {
            Warn "PreToolUse not wired in settings.json (Safety Net hook won't fire)"
        }
        if ($cfg.permissions.deny) {
            Pass "permissions.deny list present"
        } else {
            Warn "permissions.deny missing (Layer A backstop absent)"
        }
    } catch {
        Warn "settings.json exists but is not valid JSON: $_"
    }
} else {
    Warn "settings.json missing — copy from .claude/settings.example.json"
}

# -------------------- CLAUDE.md bootstrap --------------------

Section "CLAUDE.md Protocol bootstrap"
if (Test-Path "CLAUDE.md") {
    $content = Get-Content "CLAUDE.md" -Raw
    if ($content -match "BRAIN\.md|CRAFT\.md|mdbrain") {
        Pass "CLAUDE.md references mdbrain"
    } else {
        Warn "CLAUDE.md does not reference mdbrain — protocols won't auto-engage"
    }
}

# -------------------- Result --------------------

Section "Result"
$Total = $script:Pass + $script:Fail + $script:Warn
Write-Host "  Passed: $($script:Pass) / $Total"
Write-Host "  Warnings: $($script:Warn)"
Write-Host "  Failed: $($script:Fail)"

if ($script:Fail -gt 0) {
    Write-Host ""
    Write-Host "Some required components are missing. Re-run install.ps1 or fix manually." -ForegroundColor Red
    exit 1
} elseif ($script:Warn -gt 0) {
    Write-Host ""
    Write-Host "Installation is functional but some enforcement layers are incomplete." -ForegroundColor Yellow
    exit 0
} else {
    Write-Host ""
    Write-Host "All layers active. mdbrain is fully wired." -ForegroundColor Green
    exit 0
}
