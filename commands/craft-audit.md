---
description: Scan the codebase for anti-patterns per CRAFT.md (read-only, no edits)
argument-hint: "[path]"
---

Read `CRAFT.md` from the project root. Then delegate to the `craft-specialist` subagent with the following brief:

Perform a read-only Brownfield Phase 0 audit on: $ARGUMENTS (defaults to `src/` if no argument).

Steps:
1. Enumerate files under scope
2. Identify Top 10 longest files (`wc -l`, sorted desc)
3. Run the `<anti_patterns>` atlas (A1-A20) against the scope
4. Grade confidence for each finding (🟢 High / 🟡 Medium / 🔴 Low per `<safety_net>` Layer 3)
5. Cross-check against `<false_positives>` catalog — downgrade any match to 🔴 Low
6. Exclude anything matched by `.craftignore` or `@craft-*` markers
7. Rank by Impact × Ease
8. Return the `<report_template>` populated — DO NOT EDIT ANY FILES

End the report with: "Proceed with Top 3? (yes / reorder / cancel)"
