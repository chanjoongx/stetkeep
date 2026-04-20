#!/usr/bin/env bash
# stetkeep — protocol validator
#
# Verifies a project has stetkeep correctly installed and wired.
# Run from the project root after `npx stetkeep install`.
#
# Usage:
#   bash .claude/validators/validate-protocol.sh
#   bash /path/to/stetkeep/validators/validate-protocol.sh

set -u

PROJECT_DIR="${1:-$(pwd)}"
cd "$PROJECT_DIR" || { echo "ERROR: cannot cd to $PROJECT_DIR"; exit 1; }

PASS=0
FAIL=0
WARN=0

pass() { echo "  [PASS] $1"; PASS=$((PASS+1)); }
fail() { echo "  [FAIL] $1"; FAIL=$((FAIL+1)); }
warn() { echo "  [WARN] $1"; WARN=$((WARN+1)); }

section() { echo ""; echo "=== $1 ==="; }

section "Core protocol files"
for f in BRAIN.md CRAFT.md PERF.md CLAUDE.md; do
    if [ -f "$f" ]; then pass "$f present"; else fail "$f missing"; fi
done

section "Safety Net — ignore files"
for f in .craftignore .perfignore; do
    if [ -f "$f" ]; then pass "$f present"; else warn "$f missing (protection reduced)"; fi
done

section ".claude/ directory"
if [ -d ".claude" ]; then
    pass ".claude/ directory exists"
else
    fail ".claude/ directory missing — reinstall"
fi

section "Subagents (.claude/agents/)"
for agent in brain-router craft-specialist perf-specialist; do
    f=".claude/agents/${agent}.md"
    if [ -f "$f" ]; then
        if grep -q "^name: ${agent}$" "$f" 2>/dev/null; then
            pass "$agent subagent registered"
        else
            warn "$agent exists but frontmatter 'name:' mismatch"
        fi
    else
        fail "$agent subagent missing: $f"
    fi
done

section "Slash commands (.claude/commands/)"
for cmd in brain-scan craft-audit perf-audit; do
    f=".claude/commands/${cmd}.md"
    if [ -f "$f" ]; then pass "/$cmd command registered"; else fail "/$cmd command missing"; fi
done

section "Path-scoped rules (.claude/rules/)"
for rule in craft-rules perf-rules; do
    f=".claude/rules/${rule}.md"
    if [ -f "$f" ]; then
        if grep -q "^paths:" "$f" 2>/dev/null; then
            pass "$rule has paths: frontmatter"
        else
            warn "$rule exists but no paths: frontmatter (won't auto-scope)"
        fi
    else
        fail "$rule missing: $f"
    fi
done

section "Hook (.claude/hooks/safety-net.sh)"
HOOK=".claude/hooks/safety-net.sh"
if [ -f "$HOOK" ]; then
    pass "hook file exists"
    if [ -x "$HOOK" ]; then pass "hook is executable"; else warn "hook not executable (run: chmod +x $HOOK)"; fi

    # test invocation
    TEST_OUT=$(echo '{"tool_name":"Edit","tool_input":{"file_path":"legacy/test.ts"}}' | bash "$HOOK" 2>&1)
    if echo "$TEST_OUT" | grep -q 'permissionDecision'; then
        pass "hook executes and returns JSON decision"
    else
        fail "hook did not return valid JSON: $TEST_OUT"
    fi
else
    fail "hook missing: $HOOK"
fi

section "Settings (.claude/settings.json)"
SETTINGS=".claude/settings.json"
if [ -f "$SETTINGS" ]; then
    pass "settings.json exists"
    if command -v jq >/dev/null 2>&1; then
        if jq -e '.hooks.PreToolUse' "$SETTINGS" >/dev/null 2>&1; then
            pass "PreToolUse hook wired in settings"
        else
            warn "PreToolUse not wired in settings.json (Safety Net hook won't fire)"
        fi
        if jq -e '.permissions.deny' "$SETTINGS" >/dev/null 2>&1; then
            pass "permissions.deny list present"
        else
            warn "permissions.deny missing (Layer A backstop absent)"
        fi
    else
        warn "jq not installed — cannot validate JSON content"
    fi
else
    warn "settings.json missing — copy from .claude/settings.example.json"
fi

section "CLAUDE.md Protocol bootstrap"
if [ -f "CLAUDE.md" ]; then
    if grep -q "BRAIN.md\|CRAFT.md\|stetkeep" "CLAUDE.md" 2>/dev/null; then
        pass "CLAUDE.md references stetkeep"
    else
        warn "CLAUDE.md does not reference stetkeep — protocols won't auto-engage"
    fi
fi

section "Result"
TOTAL=$((PASS + FAIL + WARN))
echo "  Passed: $PASS / $TOTAL"
echo "  Warnings: $WARN"
echo "  Failed: $FAIL"

if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "Some required components are missing. Re-run 'npx stetkeep install' or fix manually."
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo ""
    echo "Installation is functional but some enforcement layers are incomplete."
    exit 0
else
    echo ""
    echo "All layers active. stetkeep is fully wired."
    exit 0
fi
