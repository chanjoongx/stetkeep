---
description: Map the project's MD ecosystem and propose next steps
---

Read `BRAIN.md` and `CLAUDE.md` from the project root. Then scan all Markdown files under the root and `docs/` (max depth 3) and classify each as:

- **Protocol**: BRAIN.md, CRAFT.md, PERF.md
- **Memory**: CLAUDE.md + anything under `memory/`
- **Legacy**: every other `.md` (README, ARCHITECTURE, CHANGELOG, docs/*, etc.)
- **Generated**: `*.pb.md`, `*.generated.md`, or files declared generated in frontmatter

Output a single report in this exact format:

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
  └─ list every other .md with its inferred role

Generated (fully ignored):
  └─ list, if any

Potential conflicts:
  - list any content overlap between Memory files
  - list any frontmatter collisions

Safety Net status:
  - .craftignore: present / missing
  - .perfignore: present / missing
  - .claude/hooks/: present / missing
  - .claude/agents/: present / missing

Suggested next steps:
  1. /craft-audit
  2. /perf-audit
  3. or specific task
```

Arguments (optional): $ARGUMENTS — if provided, use as a focus filter (e.g., `/brain-scan src/` limits scan to src/).
