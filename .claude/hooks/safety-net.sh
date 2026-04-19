#!/usr/bin/env bash
# stetkeep Safety Net — PreToolUse hook
#
# Installed via .claude/settings.json:
#   {
#     "hooks": {
#       "PreToolUse": [{
#         "matcher": "Edit|Write|Bash",
#         "hooks": [{ "type": "command", "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/safety-net.sh" }]
#       }]
#     }
#   }
#
# Enforces mechanically (not as prompt assertion):
#   - Blocks edits to paths matching .craftignore / .perfignore
#   - Blocks edits to files with @craft-ignore or @perf-optimized / @perf-hot-path markers
#   - Asks on destructive Bash commands in legacy/, generated/, vendor/
#
# Dependencies: bash 4+. jq optional (falls back to grep-based JSON parsing).

INPUT=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# ---------- JSON parsing (jq preferred, grep fallback) ----------

HAS_JQ=false
command -v jq >/dev/null 2>&1 && HAS_JQ=true

extract_field() {
    # extract_field <json_path_dot_notation>
    # $1 is e.g. ".tool_name" or ".tool_input.file_path"
    if [ "$HAS_JQ" = true ]; then
        echo "$INPUT" | jq -r "$1 // empty" 2>/dev/null
    else
        # grep-based fallback — extracts simple top-level and one-level-nested string values
        local field=$(echo "$1" | sed 's|^\.||' | sed 's|\.| |g' | awk '{print $NF}')
        echo "$INPUT" | grep -oE "\"$field\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | \
            sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/'
    fi
}

emit_decision() {
    # emit_decision <allow|ask|deny> <reason>
    local decision="$1"
    local reason="$2"

    if [ "$HAS_JQ" = true ]; then
        jq -n --arg d "$decision" --arg r "$reason" '{
          "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": $d,
            "permissionDecisionReason": $r
          }
        }'
    else
        # Hand-rolled JSON (reason is escaped for basic safety)
        local escaped_reason
        escaped_reason=$(printf '%s' "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')
        printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"%s","permissionDecisionReason":"%s"}}\n' \
            "$decision" "$escaped_reason"
    fi
}

block() { emit_decision "deny" "$1"; exit 0; }
ask()   { emit_decision "ask"  "$1"; exit 0; }

# ---------- Parse input ----------

TOOL_NAME=$(extract_field ".tool_name")
FILE_PATH=$(extract_field ".tool_input.file_path")
[ -z "$FILE_PATH" ] && FILE_PATH=$(extract_field ".tool_input.path")
BASH_CMD=$(extract_field ".tool_input.command")

# ---------- Rule: destructive or write-via-Bash in protected zones ----------
# Catches both `rm -rf legacy/` and `cat > legacy/foo.ts` — the latter is the
# Bash-based bypass of subagent Write-tool restrictions.

if [ "$TOOL_NAME" = "Bash" ] && [ -n "$BASH_CMD" ]; then
    # Destructive
    if echo "$BASH_CMD" | grep -qE "(rm -rf|rm -fr|git clean -fd)"; then
        if echo "$BASH_CMD" | grep -qE "(legacy/|generated/|vendor/|\.craftignore|\.perfignore)"; then
            block "Destructive command targets a protected zone (legacy/generated/vendor). Safety Net refusal."
        fi
        ask "Destructive command detected ('rm -rf' or similar). Confirm intent."
    fi
    # Write-via-Bash bypass (catches `cat > path`, `tee path`, `> path`, `>> path`)
    if echo "$BASH_CMD" | grep -qE ">[[:space:]]*([\"']?)(legacy|generated|vendor|node_modules|dist|build|\.next)/"; then
        block "Bash redirection targets a protected zone. Use Edit/Write tool (which is gated)."
    fi
    if echo "$BASH_CMD" | grep -qE "tee[[:space:]]+([\"']?)(legacy|generated|vendor)/"; then
        block "Bash tee targets a protected zone. Safety Net refusal."
    fi
    exit 0
fi

# Only gate Edit/Write
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
    exit 0
fi

# No file path = nothing to check
[ -z "$FILE_PATH" ] && exit 0

# Normalize relative path
REL_PATH="${FILE_PATH#$PROJECT_DIR/}"
REL_PATH="${REL_PATH#/}"

# ---------- Rule: protected path prefixes ----------

for proto in legacy/ generated/ vendor/ node_modules/ dist/ build/ .next/; do
    if [[ "$REL_PATH" == "$proto"* ]]; then
        ask "Editing $proto path ($REL_PATH). Mandatory-ask Safety Net trigger."
    fi
done

# ---------- Rule: .craftignore / .perfignore matching ----------

for ignore_file in .craftignore .perfignore; do
    IGNORE_PATH="$PROJECT_DIR/$ignore_file"
    if [ -f "$IGNORE_PATH" ]; then
        while IFS= read -r pattern || [ -n "$pattern" ]; do
            # skip comments and blank lines
            [ -z "$pattern" ] && continue
            case "$pattern" in \#*) continue;; esac
            # convert gitignore-ish glob to regex: ** -> .*  , * -> [^/]*
            regex=$(printf '%s' "$pattern" | sed 's|\.|\\.|g; s|\*\*|.*|g; s|\*|[^/]*|g')
            if [[ "$REL_PATH" =~ ^$regex$ ]]; then
                block "$REL_PATH matches $ignore_file pattern '$pattern'. Safety Net refusal."
            fi
        done < "$IGNORE_PATH"
    fi
done

# ---------- Rule: @craft-* / @perf-* markers in file ----------

if [ -f "$FILE_PATH" ]; then
    FIRST_20=$(head -n 20 "$FILE_PATH" 2>/dev/null || echo "")
    if echo "$FIRST_20" | grep -qE "@craft-ignore|@perf-optimized|@perf-hot-path|@perf-measured"; then
        MARKER=$(echo "$FIRST_20" | grep -oE "@(craft|perf)-[a-z-]+" | head -1)
        block "$REL_PATH has a $MARKER marker. Safety Net refusal — edit would regress intentional craft/performance decision."
    fi
fi

# Default: allow
exit 0
