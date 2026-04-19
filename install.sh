#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════
# mdbrain v0.2 — bash installer
#
# Installs: BRAIN/CRAFT/PERF + .claude/ (hooks, agents, rules, commands)
#           + .craftignore, .perfignore + Protocol bootstrap line in CLAUDE.md
#
# Usage:
#   bash install.sh                     # default: coexist mode
#   bash install.sh --mode fresh        # empty project
#   bash install.sh --mode merge        # append bootstrap to existing CLAUDE.md
#   bash install.sh --force             # overwrite existing files
#   bash install.sh --dry-run           # simulate, no changes
#   bash install.sh /path/to/project    # target a specific folder
# ═══════════════════════════════════════════════════════

MODE="coexist"
FORCE=false
DRY_RUN=false
PROJECT_DIR="$(pwd)"

while [ $# -gt 0 ]; do
    case "$1" in
        --mode)     MODE="$2"; shift 2 ;;
        --force|-f) FORCE=true; shift ;;
        --dry-run)  DRY_RUN=true; shift ;;
        -*)         echo "Unknown option: $1"; exit 1 ;;
        *)          PROJECT_DIR="$1"; shift ;;
    esac
done

if [[ "$MODE" != "coexist" && "$MODE" != "fresh" && "$MODE" != "merge" ]]; then
    echo "Invalid mode: $MODE (expected coexist|fresh|merge)"
    exit 1
fi

PROTOCOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "mdbrain v0.2 installer"
echo "   Source:  $PROTOCOLS_DIR"
echo "   Target:  $PROJECT_DIR"
echo "   Mode:    $MODE"
[ "$DRY_RUN" = true ] && echo "   DryRun:  active (no changes)"
echo ""

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: target folder not found: $PROJECT_DIR"
    exit 1
fi

# ═══════════════════════════════════════════════════════
# Phase 1 — Pre-scan
# ═══════════════════════════════════════════════════════

echo "Phase 1 — project scan"
echo ""

check_file() {
    local name="$1"
    local path="$PROJECT_DIR/$name"
    if [ -e "$path" ]; then
        printf "  %-22s found\n" "$name"
        return 0
    else
        printf "  %-22s -\n" "$name"
        return 1
    fi
}

HAS_CLAUDE=false
HAS_MEMORY=false
HAS_CLAUDE_DIR=false

check_file "CLAUDE.md" && HAS_CLAUDE=true || true
check_file "BRAIN.md" || true
check_file "CRAFT.md" || true
check_file "PERF.md" || true
check_file ".craftignore" || true
check_file ".perfignore" || true
check_file "memory/" && HAS_MEMORY=true || true
check_file ".claude/" && HAS_CLAUDE_DIR=true || true

OTHER_MDS=$(find "$PROJECT_DIR" -maxdepth 2 -name "*.md" -type f 2>/dev/null | \
            grep -v -E "(CLAUDE|BRAIN|CRAFT|PERF|ARCHITECTURE|CHANGELOG|CONTRIBUTING|BOOTSTRAP_GUIDE|README)\.md$" | \
            grep -v ".claude/" || true)

if [ -n "$OTHER_MDS" ]; then
    MD_COUNT=$(echo "$OTHER_MDS" | wc -l)
    echo ""
    echo "  Other MD files ($MD_COUNT):"
    echo "$OTHER_MDS" | head -10 | while read md; do
        echo "     - ${md#$PROJECT_DIR/}"
    done
    echo "     (will be classified as Legacy by BRAIN, never modified)"
fi

echo ""

# ═══════════════════════════════════════════════════════
# Phase 2 — Conflict detection
# ═══════════════════════════════════════════════════════

if [ "$HAS_CLAUDE" = true ] || [ "$HAS_MEMORY" = true ]; then
    echo "Existing project detected"
    [ "$HAS_CLAUDE" = true ] && echo "   - CLAUDE.md exists -> preserved (bootstrap line appended in coexist/merge)"
    [ "$HAS_MEMORY" = true ] && echo "   - memory/ exists -> acknowledged as project memory extension"
    [ "$HAS_CLAUDE_DIR" = true ] && echo "   - .claude/ exists -> new files added; existing preserved unless --force"

    if [ "$MODE" = "fresh" ] && [ "$FORCE" = false ]; then
        echo ""
        echo "ERROR: Fresh mode requested but existing files found. Options:"
        echo "   1. --mode coexist (default, safe): add new files, append bootstrap"
        echo "   2. --mode merge   : same + ensure Protocol section in CLAUDE.md"
        echo "   3. --force        : overwrite (dangerous)"
        exit 1
    fi
    echo ""
fi

# ═══════════════════════════════════════════════════════
# Phase 3 — Install
# ═══════════════════════════════════════════════════════

echo "Phase 3 — install"
echo ""

COPIED=0
SKIPPED=0
MERGED=0
CREATED_DIRS=0

copy_file() {
    local src="$1"
    local dst="$2"
    local src_path="$PROTOCOLS_DIR/$src"
    local dst_path="$PROJECT_DIR/$dst"

    if [ ! -f "$src_path" ]; then
        echo "WARN: source missing: $src"
        return
    fi

    if [ -f "$dst_path" ] && [ "$FORCE" = false ]; then
        echo "  skip (exists): $dst"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$(dirname "$dst_path")"
        cp "$src_path" "$dst_path"
    fi
    echo "  copy: $dst"
    COPIED=$((COPIED + 1))
}

copy_tree() {
    local src_dir="$1"
    local dst_dir="$2"
    local src_path="$PROTOCOLS_DIR/$src_dir"
    local dst_path="$PROJECT_DIR/$dst_dir"

    if [ ! -d "$src_path" ]; then return; fi

    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$dst_path"
    fi

    for f in "$src_path"/*; do
        if [ -f "$f" ]; then
            local name=$(basename "$f")
            local dest="$dst_path/$name"
            if [ -f "$dest" ] && [ "$FORCE" = false ]; then
                echo "  skip (exists): $dst_dir/$name"
                SKIPPED=$((SKIPPED + 1))
            else
                [ "$DRY_RUN" = false ] && cp "$f" "$dest"
                echo "  copy: $dst_dir/$name"
                COPIED=$((COPIED + 1))
            fi
        fi
    done
}

# Core protocol files
copy_file "BRAIN.md" "BRAIN.md"
copy_file "CRAFT.md" "CRAFT.md"
copy_file "PERF.md" "PERF.md"
copy_file "ARCHITECTURE.md" "ARCHITECTURE.md"
copy_file "BOOTSTRAP_GUIDE.md" "BOOTSTRAP_GUIDE.md"

# .claude/ directory (agents, hooks, rules, commands, settings.example.json)
echo ""
echo "  .claude/ directory:"
copy_tree ".claude/agents"   ".claude/agents"
copy_tree ".claude/hooks"    ".claude/hooks"
copy_tree ".claude/rules"    ".claude/rules"
copy_tree ".claude/commands" ".claude/commands"
copy_file ".claude/settings.example.json" ".claude/settings.example.json"

# Make the bash hook executable
if [ -f "$PROJECT_DIR/.claude/hooks/safety-net.sh" ] && [ "$DRY_RUN" = false ]; then
    chmod +x "$PROJECT_DIR/.claude/hooks/safety-net.sh"
fi

# Benchmark + validators
copy_file "benchmark/SPEC.md" "benchmark/SPEC.md"
copy_file "validators/validate-protocol.sh" "validators/validate-protocol.sh"
if [ -f "$PROJECT_DIR/validators/validate-protocol.sh" ] && [ "$DRY_RUN" = false ]; then
    chmod +x "$PROJECT_DIR/validators/validate-protocol.sh"
fi

# CLAUDE.md — mode-dependent
CLAUDE_SRC="$PROTOCOLS_DIR/CLAUDE.template.md"
CLAUDE_DST="$PROJECT_DIR/CLAUDE.md"
CLAUDE_TEMPLATE_DST="$PROJECT_DIR/CLAUDE.template.md"

BOOTSTRAP_LINE='
## 🧠 Protocol bootstrap (mdbrain)

For every code task, read these before acting: `BRAIN.md`, `CRAFT.md`, `PERF.md`.
They define routing, anti-pattern detection, performance discipline, and the Safety Net.
The mechanical Safety Net (`.claude/hooks/safety-net.sh`) runs independently and will
block edits to protected paths regardless of in-session context.

Run `/brain-scan` at session start to see the MD ecosystem map.
'

echo ""
if [ "$HAS_CLAUDE" = true ]; then
    case "$MODE" in
        coexist|merge)
            # Check if bootstrap already exists
            if ! grep -q "mdbrain\|BRAIN.md" "$CLAUDE_DST" 2>/dev/null; then
                if [ "$DRY_RUN" = false ]; then
                    printf "%s" "$BOOTSTRAP_LINE" >> "$CLAUDE_DST"
                fi
                echo "  append: CLAUDE.md Protocol bootstrap line added"
                MERGED=$((MERGED + 1))
            else
                echo "  skip: CLAUDE.md already references mdbrain"
                SKIPPED=$((SKIPPED + 1))
            fi
            [ "$DRY_RUN" = false ] && cp "$CLAUDE_SRC" "$CLAUDE_TEMPLATE_DST" 2>/dev/null || true
            COPIED=$((COPIED + 1))
            ;;
        fresh)
            if [ "$FORCE" = true ]; then
                BACKUP="$CLAUDE_DST.backup-$(date +%Y%m%d-%H%M%S)"
                if [ "$DRY_RUN" = false ]; then
                    mv "$CLAUDE_DST" "$BACKUP"
                    cp "$CLAUDE_SRC" "$CLAUDE_DST"
                fi
                echo "  overwrite: CLAUDE.md (backup: $BACKUP)"
                COPIED=$((COPIED + 1))
            fi
            ;;
    esac
else
    [ "$DRY_RUN" = false ] && cp "$CLAUDE_SRC" "$CLAUDE_DST"
    echo "  create: CLAUDE.md (from template, needs filling in)"
    COPIED=$((COPIED + 1))
fi

# .craftignore / .perfignore
if [ ! -f "$PROJECT_DIR/.craftignore" ]; then
    if [ "$DRY_RUN" = false ]; then
        cat > "$PROJECT_DIR/.craftignore" << 'EOF'
# CRAFT refactor exclusion paths (gitignore-style)
generated/**
vendor/**
node_modules/**
dist/**
build/**
.next/**
*.generated.ts
*.pb.js
EOF
    fi
    echo "  create: .craftignore"
    COPIED=$((COPIED + 1))
fi

if [ ! -f "$PROJECT_DIR/.perfignore" ]; then
    if [ "$DRY_RUN" = false ]; then
        cat > "$PROJECT_DIR/.perfignore" << 'EOF'
# PERF optimization exclusion paths
generated/**
node_modules/**
dist/**
build/**
.next/**
tests/**
scripts/**
*.min.js
EOF
    fi
    echo "  create: .perfignore"
    COPIED=$((COPIED + 1))
fi

# ═══════════════════════════════════════════════════════
# Phase 4 — Done + guidance
# ═══════════════════════════════════════════════════════

echo ""
echo "─────────────────────────────────────"
echo "Install complete"
echo "   copied: $COPIED  |  bootstrap-merged: $MERGED  |  skipped: $SKIPPED"
[ "$DRY_RUN" = true ] && echo "   (dry run — no changes applied)"
echo ""

echo "Next steps:"
echo ""
echo "  1. Wire the Safety Net hook (one-time):"
echo "     cp .claude/settings.example.json .claude/settings.json"
echo "     (review the file — permissions deny list protects legacy/, generated/, vendor/)"
echo ""

if [ "$HAS_CLAUDE" = true ] && [ "$MODE" = "coexist" ]; then
    echo "  2. Your existing CLAUDE.md was preserved. A Protocol bootstrap line was appended."
    echo "     Review and keep project-specific constraints at the top."
elif [ ! "$HAS_CLAUDE" = true ]; then
    echo "  2. Fill in CLAUDE.md with your project facts"
    echo "     (project name, stack, constraints, user context)"
fi

echo ""
echo "  3. Verify installation:"
echo "     bash validators/validate-protocol.sh"
echo ""
echo "  4. Launch Claude Code:"
echo "     claude"
echo ""
echo "  5. First command:"
echo "     /brain-scan"
echo ""
echo "  Docs: README.md, ARCHITECTURE.md, BOOTSTRAP_GUIDE.md, benchmark/SPEC.md"
echo ""
