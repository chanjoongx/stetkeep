# BOOTSTRAP_GUIDE.md — First Session Walkthrough

> How to use stetkeep in a fresh Claude Code session.
> As of 2026, most of this happens automatically via native Claude Code mechanisms.

---

## What auto-loads (you do nothing)

Claude Code automatically loads on session start:

- **`CLAUDE.md`** (project root) — project facts, constraints
- **`~/.claude/CLAUDE.md`** — user-global preferences (if you have one)
- **`~/.claude/projects/<hash>/memory/MEMORY.md`** + linked files — auto-memory system
- **Managed policy CLAUDE.md** (if org-enforced)

Claude Code **auto-loads path-scoped rules on file access**:

- **`.claude/rules/*.md`** with `paths:` frontmatter — loaded when Claude reads a matching file
  (e.g., our `.claude/rules/craft-rules.md` loads whenever Claude reads `src/**/*.ts`)

Claude Code makes **subagents and slash commands available** automatically:

- **`.claude/agents/*.md`** — subagents become delegatable; Claude picks them based on their `description` field
- **`.claude/commands/*.md`** — slash commands are registered (e.g., `/brain-scan`, `/craft-audit`)

Claude Code runs **configured hooks**:

- **`.claude/hooks/*`** (wired in `.claude/settings.json`) — PreToolUse, SessionStart, etc. Run outside the LLM.

---

## What you still type (session bootstrap)

**None of the above loads `BRAIN.md`, `CRAFT.md`, or `PERF.md` directly.**
They're referenced by the subagents and rules, but for orchestration visibility:

**Canonical first command:**
```
/brain-scan
```

That runs `.claude/commands/brain-scan.md`, which loads `BRAIN.md` and reports the MD ecosystem map.

**If slash commands aren't available yet** (you ran `install` but haven't restarted `claude`, or you're using plain protocol files without the plugin):
```
Read BRAIN.md and map this project's MD ecosystem. Classify each .md file as
Protocol / Memory / Legacy / Generated.
```

---

## Expected output from `/brain-scan`

```
MD Ecosystem Map

Protocols:
  ├─ BRAIN.md
  ├─ CRAFT.md
  └─ PERF.md

Memory (context):
  ├─ CLAUDE.md
  └─ memory/... (if present)

Legacy (read-only, never modified):
  └─ README.md, CHANGELOG.md, docs/* ...

Safety Net status:
  - .craftignore: present
  - .perfignore: present
  - .claude/hooks/safety-net.sh: present (PreToolUse wired)
  - .claude/agents/: 3 agents (brain-router, craft-specialist, perf-specialist)
  - .claude/commands/: 3 commands
  - .claude/rules/: 2 rules (path-scoped for src/**)

Suggested next steps:
  1. /craft-audit
  2. /perf-audit
  3. or specific task
```

---

## Command map by starting state

### Fresh / greenfield (empty or just package.json)

```
Read BRAIN.md, then enter CRAFT Greenfield mode.
```
BRAIN will ask you for a 1-paragraph README vision before any code.

### Existing messy brownfield

```
/brain-scan
/craft-audit
/perf-audit
Combined report — propose priority.
```

### Existing rich project (CLAUDE.md + memory/ already populated)

```
/brain-scan
```
Then review the classification. Fix any misclassifications with:
```
Reclassify {file} as {Protocol|Memory|Legacy}.
```

### Specific task

```
/brain-scan     # once per session, 30s
{your task in natural language}
```

---

## What happens under the hood when you ask to refactor

You say: **"clean up src/components/"**

1. Claude sees CLAUDE.md (auto-loaded) and its protocol bootstrap line
2. Claude reads `src/components/` — this triggers `.claude/rules/craft-rules.md` auto-load (path-scoped)
3. Claude delegates to `craft-specialist` subagent (tool-scoped: no Write, no bypass of Safety Net)
4. craft-specialist follows CRAFT.md workflow — audits first, waits for approval
5. On your approval, it edits. Every Edit call goes through `.claude/hooks/safety-net.sh` which checks:
   - Is the path in `.craftignore`? → deny
   - Does the file start with `@craft-ignore`? → deny
   - Is the path under `legacy/` / `generated/` / `vendor/`? → ask
6. If the hook allows, the edit proceeds

Notice what you didn't need to type: "Read BRAIN.md", "check the Safety Net", "grade confidence". The mechanisms are wired.

---

## Common pitfalls

### Pitfall 1 — No `.claude/settings.json` in your project

If you installed stetkeep but didn't copy `.claude/settings.json`, hooks won't wire. Safety Net becomes prompt-only.

**Fix**: `cp .claude/settings.example.json .claude/settings.json` and customize.

### Pitfall 2 — Subagents not discovered

Claude Code scans `.claude/agents/` at session start. If you added an agent during a session, restart `claude` to pick it up.

### Pitfall 3 — Path-scoped rules not triggering

Rules in `.claude/rules/` only load when Claude *reads* a matching file. If your task doesn't involve reading a `src/**` file, craft-rules won't activate. That's expected — not all tasks need CRAFT.

### Pitfall 4 — Hooks silently failing

If `.claude/hooks/safety-net.sh` has a bug or wrong path, hooks fail open (Claude proceeds). Test with:
```
echo '{"tool_name":"Edit","tool_input":{"file_path":"legacy/test.ts"}}' | bash .claude/hooks/safety-net.sh
```
Should return JSON with `"permissionDecision":"ask"`.

---

## Minimum viable first turn

If you just want to work:

```
/brain-scan
```

One command. 30 seconds. Everything else auto-loads as needed.

---

## Advanced: preload everything into context

For long planning sessions where you want full routing visibility from turn 1:

```
Read BRAIN.md, CRAFT.md, PERF.md, and CLAUDE.md.
Run /brain-scan.
Give me the ecosystem map + initial CRAFT audit + PERF budget check.
```

Token cost: ~7-9K tokens on first turn (down from ~15-18K in the pre-compression era). Worth it for full-day sessions.
