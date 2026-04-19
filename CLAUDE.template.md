# CLAUDE.md — {PROJECT_NAME}

> Project memory. Auto-loaded by Claude Code every session.

---

## 🧠 Protocol bootstrap (stetkeep)

**For every code task, read these before acting**: `BRAIN.md`, `CRAFT.md`, `PERF.md`.
They define routing, anti-pattern detection, performance discipline, and the Safety Net.
The mechanical Safety Net (`.claude/hooks/safety-net.sh`) runs independently and will
block edits to protected paths regardless of in-session context.

Run `/brain-scan` at session start to see the MD ecosystem map.

---

## Project Overview

**{PROJECT_NAME}** — [what it does, in one sentence].

- **Started**: YYYY-MM-DD
- **Stack**: [e.g., Next.js 15 + TypeScript + Supabase]
- **Deployment**: [e.g., Vercel, Cloudflare Workers]
- **Key libraries**: [3-5 critical deps]

---

## Core Facts (invariants)

### Data model
- [Entity 1]: [description]
- [Entity 2]: [description]

### Domain rules
- [Business rule 1]
- [Business rule 2]

### External contracts
- API: [name + URL + version]
- DB: [name + schema location]

---

## Constraints (hard rules)

### Never touch
- `generated/**` — auto-generated code
- `vendor/**` — external dep copies
- `legacy/**` — deprecated but still required
- [project-specific paths]

### Legacy zones with reasons
- [path]: [why kept, planned removal date]

### External API contracts
- [public interfaces that must not change without version bump]

---

## User Context

- **Name**: [who]
- **Role**: [developer / student / etc.]
- **Communication preference**: [language, tone, detail level]

---

## Current Status

- **Last session**: YYYY-MM-DD
- **Next goal**: [one line]
- **Known issues**: [brief bug list]

---

## References

### Project-internal
- `BRAIN.md` — MD pipeline orchestrator
- `CRAFT.md` — code artistry + anti-pattern atlas
- `PERF.md` — performance optimization + measurement discipline
- `.claude/agents/` — tool-scoped subagents
- `.claude/hooks/safety-net.sh` — mechanical Safety Net
- `.claude/rules/` — path-scoped rules (auto-loaded on src/** access)
- `.claude/commands/` — slash commands: /brain-scan, /craft-audit, /perf-audit
- `.claude/settings.example.json` — example hook/permission wiring

### External
- Domain docs: [URL]
- Design: [Figma / URL]
- Team wiki: [URL]

---

## AI Collaboration Rules

1. Read this file first (Claude Code auto-loads it)
2. For code tasks, also load BRAIN/CRAFT/PERF per the bootstrap line above
3. Never violate constraints (legacy / generated / vendor)
4. Ask when uncertain — no silent assumptions
5. Record important decisions by updating this file
