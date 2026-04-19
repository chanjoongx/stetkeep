---
paths:
  - "src/**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "lib/**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "app/**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "packages/**/*.{ts,tsx,js,jsx,mjs,cjs}"
---

# Rule: CRAFT Safety Net (path-scoped)

Loaded automatically when Claude reads or edits files in src/, lib/, app/, or packages/.

## Before editing any file in scope

<pre_action_checklist>
1. Did I run the Pre-Action 4-question self-check (CRAFT.md Layer 4)?
2. Did I check this file for `@craft-*` markers? (if present → skip)
3. Is this path matched by `.craftignore`? (if yes → skip)
4. What confidence grade (🟢/🟡/🔴) am I at for this edit? (do not upgrade to skip approval)
5. Does this edit span >100 lines or >3 files? (if yes → require approval before starting)
</pre_action_checklist>

## Forbidden without user approval

- Editing files listed in `.craftignore`
- Editing lines with any `@craft-*` marker
- Touching `legacy/`, `generated/`, `vendor/`, `dist/`, `build/`
- Changing public API signatures (exported types, public components)
- Edits spanning 100+ lines
- Edits touching 3+ files simultaneously
- Adding new dependencies
- Deleting files without dead-code confirmation

## False-positive mandatory check

Before flagging any pattern from CRAFT.md `<anti_patterns>`, cross-check CRAFT.md `<false_positives>` catalog. On any match, downgrade to 🔴 Low confidence and ask the user first.

## Reason markers

If you deliberately skip a CRAFT rule for a legitimate reason, add:
```
// @craft-ignore reason="<specific reason>"
```
The `reason=` field is REQUIRED.

## Behavior

- Report anti-pattern findings using CRAFT.md `<report_template>`
- One fix per git commit with the pattern ID in the message
- Self-score CRAFT.md `<decision_matrix>` after each edit
- Stop and revert on any test regression
