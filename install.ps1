# ═══════════════════════════════════════════════════════
# mdbrain v0.2 — PowerShell installer
#
# Installs: BRAIN/CRAFT/PERF + .claude/ (hooks, agents, rules, commands)
#           + .craftignore, .perfignore + Protocol bootstrap line in CLAUDE.md
#
# Usage:
#   powershell -File install.ps1                           # default: coexist
#   powershell -File install.ps1 -Mode fresh               # empty project
#   powershell -File install.ps1 -Mode merge               # append bootstrap
#   powershell -File install.ps1 -Force                    # overwrite existing
#   powershell -File install.ps1 -DryRun                   # simulate
#   powershell -File install.ps1 -ProjectDir "C:\path"     # target specific
# ═══════════════════════════════════════════════════════

param(
    [string]$ProjectDir = (Get-Location).Path,
    [ValidateSet("coexist", "fresh", "merge")]
    [string]$Mode = "coexist",
    [switch]$Force = $false,
    [switch]$DryRun = $false
)

$ProtocolsDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "mdbrain v0.2 installer" -ForegroundColor Cyan
Write-Host "   Source:  $ProtocolsDir"
Write-Host "   Target:  $ProjectDir"
Write-Host "   Mode:    $Mode" -ForegroundColor Yellow
if ($DryRun) { Write-Host "   DryRun:  active (no changes)" -ForegroundColor Magenta }
Write-Host ""

if (-not (Test-Path $ProjectDir)) {
    Write-Host "ERROR: target folder not found: $ProjectDir" -ForegroundColor Red
    exit 1
}

# ═══════════════════════════════════════════════════════
# Phase 1 — Pre-scan
# ═══════════════════════════════════════════════════════

Write-Host "Phase 1 — project scan" -ForegroundColor Cyan
Write-Host ""

$ExistingFiles = @{
    "CLAUDE.md"    = Test-Path (Join-Path $ProjectDir "CLAUDE.md")
    "BRAIN.md"     = Test-Path (Join-Path $ProjectDir "BRAIN.md")
    "CRAFT.md"     = Test-Path (Join-Path $ProjectDir "CRAFT.md")
    "PERF.md"      = Test-Path (Join-Path $ProjectDir "PERF.md")
    ".craftignore" = Test-Path (Join-Path $ProjectDir ".craftignore")
    ".perfignore"  = Test-Path (Join-Path $ProjectDir ".perfignore")
    "memory/"      = Test-Path (Join-Path $ProjectDir "memory")
    ".claude/"     = Test-Path (Join-Path $ProjectDir ".claude")
}

foreach ($file in $ExistingFiles.GetEnumerator()) {
    $status = if ($file.Value) { "found" } else { "-" }
    $color = if ($file.Value) { "Yellow" } else { "DarkGray" }
    Write-Host ("  {0,-22} {1}" -f $file.Key, $status) -ForegroundColor $color
}

Write-Host ""

# ═══════════════════════════════════════════════════════
# Phase 2 — Conflict detection
# ═══════════════════════════════════════════════════════

$HasExistingClaude = $ExistingFiles["CLAUDE.md"]
$HasMemoryFolder   = $ExistingFiles["memory/"]
$HasClaudeDir      = $ExistingFiles[".claude/"]

if ($HasExistingClaude -or $HasMemoryFolder) {
    Write-Host "Existing project detected" -ForegroundColor Yellow
    if ($HasExistingClaude) { Write-Host "   - CLAUDE.md exists -> preserved (bootstrap appended)" -ForegroundColor Yellow }
    if ($HasMemoryFolder)   { Write-Host "   - memory/ exists -> acknowledged as project memory extension" -ForegroundColor Yellow }
    if ($HasClaudeDir)      { Write-Host "   - .claude/ exists -> new files added unless -Force" -ForegroundColor Yellow }

    if ($Mode -eq "fresh" -and -not $Force) {
        Write-Host ""
        Write-Host "ERROR: Fresh mode requested but existing files found. Options:" -ForegroundColor Red
        Write-Host "   1. -Mode coexist (default, safe): add new files, append bootstrap"
        Write-Host "   2. -Mode merge : same + ensure Protocol section in CLAUDE.md"
        Write-Host "   3. -Force      : overwrite (dangerous)"
        exit 1
    }
    Write-Host ""
}

# ═══════════════════════════════════════════════════════
# Phase 3 — Install
# ═══════════════════════════════════════════════════════

Write-Host "Phase 3 — install" -ForegroundColor Cyan
Write-Host ""

$Copied = 0
$Skipped = 0
$Merged = 0

function Copy-ProtocolFile {
    param([string]$Src, [string]$Dst)
    $srcPath = Join-Path $ProtocolsDir $Src
    $dstPath = Join-Path $ProjectDir $Dst
    if (-not (Test-Path $srcPath)) { Write-Host "WARN: source missing: $Src" -ForegroundColor Yellow; return }
    if ((Test-Path $dstPath) -and -not $Force) {
        Write-Host "  skip (exists): $Dst" -ForegroundColor Gray
        $script:Skipped++; return
    }
    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path (Split-Path $dstPath) | Out-Null
        Copy-Item $srcPath $dstPath -Force
    }
    Write-Host "  copy: $Dst" -ForegroundColor Green
    $script:Copied++
}

function Copy-ProtocolTree {
    param([string]$SrcDir, [string]$DstDir)
    $srcPath = Join-Path $ProtocolsDir $SrcDir
    $dstPath = Join-Path $ProjectDir $DstDir
    if (-not (Test-Path $srcPath)) { return }
    if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $dstPath | Out-Null }
    Get-ChildItem -Path $srcPath -File | ForEach-Object {
        $destFile = Join-Path $dstPath $_.Name
        if ((Test-Path $destFile) -and -not $Force) {
            Write-Host "  skip (exists): $DstDir/$($_.Name)" -ForegroundColor Gray
            $script:Skipped++
        } else {
            if (-not $DryRun) { Copy-Item $_.FullName $destFile -Force }
            Write-Host "  copy: $DstDir/$($_.Name)" -ForegroundColor Green
            $script:Copied++
        }
    }
}

# Core protocol files
Copy-ProtocolFile "BRAIN.md"            "BRAIN.md"
Copy-ProtocolFile "CRAFT.md"            "CRAFT.md"
Copy-ProtocolFile "PERF.md"             "PERF.md"
Copy-ProtocolFile "ARCHITECTURE.md"     "ARCHITECTURE.md"
Copy-ProtocolFile "BOOTSTRAP_GUIDE.md"  "BOOTSTRAP_GUIDE.md"

# .claude/ directory
Write-Host ""
Write-Host "  .claude/ directory:"
Copy-ProtocolTree ".claude/agents"   ".claude/agents"
Copy-ProtocolTree ".claude/hooks"    ".claude/hooks"
Copy-ProtocolTree ".claude/rules"    ".claude/rules"
Copy-ProtocolTree ".claude/commands" ".claude/commands"
Copy-ProtocolFile ".claude/settings.example.json" ".claude/settings.example.json"

# Benchmark + validators
Copy-ProtocolFile "benchmark/SPEC.md"                  "benchmark/SPEC.md"
Copy-ProtocolFile "validators/validate-protocol.sh"    "validators/validate-protocol.sh"

# CLAUDE.md — mode-dependent
$ClaudeSrc = Join-Path $ProtocolsDir "CLAUDE.template.md"
$ClaudeDst = Join-Path $ProjectDir "CLAUDE.md"
$ClaudeTemplateDst = Join-Path $ProjectDir "CLAUDE.template.md"

$Bootstrap = @'


## 🧠 Protocol bootstrap (mdbrain)

For every code task, read these before acting: `BRAIN.md`, `CRAFT.md`, `PERF.md`.
They define routing, anti-pattern detection, performance discipline, and the Safety Net.
The mechanical Safety Net (`.claude/hooks/safety-net.ps1`) runs independently and will
block edits to protected paths regardless of in-session context.

Run `/brain-scan` at session start to see the MD ecosystem map.

'@

Write-Host ""
if ($HasExistingClaude) {
    switch ($Mode) {
        { $_ -eq "coexist" -or $_ -eq "merge" } {
            $existing = Get-Content $ClaudeDst -Raw -ErrorAction SilentlyContinue
            if ($existing -notmatch "mdbrain|BRAIN\.md") {
                if (-not $DryRun) { Add-Content -Path $ClaudeDst -Value $Bootstrap }
                Write-Host "  append: CLAUDE.md Protocol bootstrap line added" -ForegroundColor Green
                $Merged++
            } else {
                Write-Host "  skip: CLAUDE.md already references mdbrain" -ForegroundColor Gray
                $Skipped++
            }
            if (-not $DryRun) { Copy-Item $ClaudeSrc $ClaudeTemplateDst -Force -ErrorAction SilentlyContinue }
            $Copied++
        }
        "fresh" {
            if ($Force) {
                $backup = "$ClaudeDst.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                if (-not $DryRun) {
                    Move-Item $ClaudeDst $backup
                    Copy-Item $ClaudeSrc $ClaudeDst -Force
                }
                Write-Host "  overwrite: CLAUDE.md (backup: $backup)" -ForegroundColor Green
                $Copied++
            }
        }
    }
} else {
    if (-not $DryRun) { Copy-Item $ClaudeSrc $ClaudeDst -Force }
    Write-Host "  create: CLAUDE.md (from template, needs filling in)" -ForegroundColor Green
    $Copied++
}

# .craftignore / .perfignore
if (-not (Test-Path (Join-Path $ProjectDir ".craftignore"))) {
    if (-not $DryRun) {
        @"
# CRAFT refactor exclusion paths (gitignore-style)
generated/**
vendor/**
node_modules/**
dist/**
build/**
.next/**
*.generated.ts
*.pb.js
"@ | Out-File -FilePath (Join-Path $ProjectDir ".craftignore") -Encoding ASCII
    }
    Write-Host "  create: .craftignore" -ForegroundColor Green
    $Copied++
}

if (-not (Test-Path (Join-Path $ProjectDir ".perfignore"))) {
    if (-not $DryRun) {
        @"
# PERF optimization exclusion paths
generated/**
node_modules/**
dist/**
build/**
.next/**
tests/**
scripts/**
*.min.js
"@ | Out-File -FilePath (Join-Path $ProjectDir ".perfignore") -Encoding ASCII
    }
    Write-Host "  create: .perfignore" -ForegroundColor Green
    $Copied++
}

# ═══════════════════════════════════════════════════════
# Phase 4 — Done + guidance
# ═══════════════════════════════════════════════════════

Write-Host ""
Write-Host "─────────────────────────────────────" -ForegroundColor Cyan
Write-Host "Install complete" -ForegroundColor Cyan
Write-Host "   copied: $Copied  |  bootstrap-merged: $Merged  |  skipped: $Skipped"
if ($DryRun) { Write-Host "   (dry run — no changes applied)" -ForegroundColor Magenta }
Write-Host ""

Write-Host "Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Wire the Safety Net hook (one-time):"
Write-Host "     Copy-Item .claude/settings.example.json .claude/settings.json"
Write-Host "     (review the file — permissions deny list protects legacy/, generated/, vendor/)"
Write-Host ""

if ($HasExistingClaude -and $Mode -eq "coexist") {
    Write-Host "  2. Your existing CLAUDE.md was preserved. Protocol bootstrap line appended."
    Write-Host "     Review and keep project-specific constraints at the top."
} elseif (-not $HasExistingClaude) {
    Write-Host "  2. Fill in CLAUDE.md with your project facts"
    Write-Host "     (project name, stack, constraints, user context)"
}

Write-Host ""
Write-Host "  3. Verify installation:"
Write-Host "     bash validators/validate-protocol.sh"
Write-Host ""
Write-Host "  4. Launch Claude Code:"
Write-Host "     claude" -ForegroundColor Yellow
Write-Host ""
Write-Host "  5. First command:"
Write-Host "     /brain-scan" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Docs: README.md, ARCHITECTURE.md, BOOTSTRAP_GUIDE.md, benchmark/SPEC.md"
Write-Host ""
