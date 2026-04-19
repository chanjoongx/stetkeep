# CRAFT.md — Code Artistry Protocol

<mission>
Write code that a first-time reader can understand after skimming 1-2 files.
North star: "Small core. Composable growth. No magic. Delete is art."
Trigger phrases: "follow CRAFT.md", "CRAFT mode", "make this artistic".
</mission>

<constraints>
1. One file = one role; filename explains it in <20 words.
2. Core API <=10 primitives; grow via composition, not options bloat.
3. Explicit > implicit. Declare deps via params/returns, not globals.
4. AHA: tolerate duplication until 3rd occurrence, then extract.
5. Every public function has a typed signature (TS or JSDoc).
6. Prefer `Result<T,E>` return over throw; reserve exceptions for I/O/OOM.
7. Before adding a dep: can I write it in 20 lines? can existing deps do it? do I need it?
8. Tests double as usage docs.
9. File order: imports -> types -> star export -> helpers -> internals.
10. Deletion is the purest refactor. Find one deletion per session.
</constraints>

<decision_matrix>
Pass = 8/10 YES. Otherwise refactor.
1. Do the top 10 lines explain the file?
2. Is every function <30 lines (except render/parser)?
3. Is every file <200 lines?
4. Does the filename describe the role in <20 words?
5. Are required deps <5?
6. Are props/return types declared?
7. Is the same logic repeated <3 times?
8. Is there zero deletable code?
9. Do tests act as usage examples?
10. Do imports survive a file move?
</decision_matrix>

<modes>
GREENFIELD (empty dir or only package.json):
  1. Demand a 1-paragraph README vision before any code.
  2. Identify 1-2 core primitives; if not stateable in one sentence, stop.
  3. Types first (<50 lines, include `Result<T,E>`).
  4. Minimal happy-path implementation (<100 lines).
  5. First test = first docs.
  6. Define the `index.ts` export boundary.
  7. Exactly one extension mechanism (plugin OR middleware OR composition).
  8. Anti-pattern audit before commit.

BROWNFIELD (existing src/):
  P0 Audit (read-only): longest 10 files (`wc -l`), exports/file, dup imports -> AUDIT.md.
  P1 Scan the anti-pattern atlas.
  P2 Prioritize by Impact x Ease.
  P3 Rules: 1 commit = 1 anti-pattern; no new features; tests first; <10 lines/change; deletion first.
  P4 Apply transformations.
  P5 Re-score the matrix; LOC should not grow; deps should not grow.
  P6 Final delete sweep.
</modes>

<anti_patterns>
| ID | Pattern | Detect | Fix |
|---|---|---|---|
| A1 | God file/component | >300 LOC, >10 fns | Split by responsibility |
| A2 | Prop drilling | Same prop 3+ layers | Context / Zustand / jotai |
| A3 | Copy-paste duplication | 20+ identical lines, 3+ places | Extract util (respect AHA) |
| A4 | Magic numbers/strings | `3600000`, raw enums | Named const / config |
| A5 | Deep nesting | 4+ if levels | Guard clauses + early return |
| A6 | Boolean trap | `fn(true,false,true)` | Options object |
| A7 | Primitive obsession | Bare `userId: string` leaking | Branded types |
| A8 | Long params (4+) | `fn(a,b,c,d,e)` | Options object / split |
| A9 | Shotgun surgery | Edit scatters across 5+ files | Centralize domain |
| A10 | Dead code | Unused imports/exports/comments | Delete now (git remembers) |
| A11 | Inconsistent naming | get/fetch/load mix | Pick one convention |
| A12 | Silent failure | `catch {}` | Warn + explicit fallback |
| A13 | Implicit coupling | Reads B's internals | Explicit contract |
| A14 | Premature abstraction | 1-use factory | YAGNI, delete |
| A15 | Over-engineering | Factory+Strategy for a simple case | Simplest implementation |
| A16 | Stringly-typed | Magic string args | Union/enum |
| A17 | Hidden side effects | `getX` also caches/logs | Rename to reveal |
| A18 | Overloaded abstraction | 1 class does 5 things | Split |
| A19 | Feature envy | `A.method` uses `B`'s fields | Move to B |
| A20 | Comment instead of refactor | `// TODO: careful` | Rename + split |
</anti_patterns>

<transformations>
T1 God -> hooks+subcomponents. T2 Drilling -> context/store. T3 Dup -> util. T4 Magic -> named config.
T5 Nesting -> guard clauses. T6 Boolean -> options obj. T7 Primitive -> branded type. T8 Long params -> options obj.
T9 Multi-file change -> domain module. T10 Dead code -> delete.
</transformations>

<safety_net>
Layer 1 — Inline markers (skip the file/block):
  `// @craft-ignore reason="..."`
  `// @craft-exempt-length reason="..."`
  `// @craft-exempt-duplication reason="..."`
  `// @craft-legacy reason="..."`
  `reason=` is REQUIRED.

Layer 2 — `.craftignore` at repo root (gitignore-style). Typical entries:
  generated/**, *.pb.js, *.generated.ts, vendor/**, node_modules/**,
  dist/**, build/**, .next/**, tests/fixtures/**, __mocks__/**, legacy/**

Layer 3 — Confidence grading (bias toward the safer grade; do not relabel to skip confirmation):
  High: dead code, unused imports, 100% identical duplication -> auto-fix OK.
  Medium: 300+ LOC files, prop drilling, magic numbers -> user confirm.
  Low: domain logic, framework idioms, unclear intent -> always ask.

Layer 4 — Pre-action self-check (any "not sure" => ask):
  1. Could the author have had a reason?
  2. Is there a constraint in CLAUDE.md / README covering this?
  3. Could this break behavior / external API / tests?
  4. Is the blast radius large (strong coupling)?

Layer 5 — Mandatory-ask triggers (always require approval):
  - Change spans 100+ lines
  - 3+ files edited in one step
  - Anything inside legacy/, generated/, vendor/
  - Large-scale edits under tests/
  - Changing external API signatures / exported types
  - DB schema / migrations
  - Auth / security code
  - Public component API consumed by other apps
</safety_net>

<false_positives>
| Situation | AI will misjudge as | Actually |
|---|---|---|
| 1000-line config/data file | A1 God File | Constants; splitting causes confusion |
| Deliberate inline for-loop | A3 Duplication | Profiled; 10x faster than generic extraction |
| 400-line `validate_tax_calc` | A1 Long Function | Domain complexity; splitting loses context |
| Legacy API wrapper | A15 Over-engineering | Compatibility required |
| `*.pb.ts` generated code | A10 Dead Code | Regen destroys edits |
| Verbose test mocks | A3 Duplication | Clarity > DRY in tests |
| Suspense / ErrorBoundary | "strange structure" | React-specific idiom |
| Tiny team using primitive types | A7 Primitive Obsession | Deliberate anti-over-engineering |

Any match => 🔴 Low confidence, confirm first.
</false_positives>

<execution_rules>
1. No edit without stating "here's why this is better".
2. One session = one anti-pattern; never batch.
3. Refactor preserves behavior only; no new features.
4. Broken tests => immediate rollback, no push-through.
5. Self-score the Decision Matrix after each change; report the number.
6. One fix = one git commit (`refactor(craft): A1 split UserDashboard`).
7. Single commit <=500 lines. No leftover `// TODO`.
8. Prefer suggesting tests when absent; don't force them.
</execution_rules>

<report_template>
## CRAFT Audit Report
- Total files: N; Top 5 longest files with LOC.
- Decision Matrix: X/10.
- Anti-patterns found (ID + location + evidence).
- Refactor plan: table of [ID | Impact | Effort | Rank].
- "Proceed?" — wait for approval before any edit.
</report_template>

<north_star>
Code is written to be read; machine execution is a side effect.
If the next reader cannot grasp it in 30 seconds, it failed.
When in doubt: delete + rewrite > patch + comment.
But: ask before doubting. False positives are the worst sin.
</north_star>
