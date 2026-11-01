<!-- FADE progress.md v0.3.1 -->

# Progress Log

Session history for this project. Append-only.

<!--
Entry format (append new entries below the line):

## YYYY-MM-DD HH:MM - US-XXX: Story Title - COMPLETE

- Summary of what was implemented
- Files changed: list key files
- Tests: passed/added

For blocked stories, use:

## YYYY-MM-DD HH:MM - US-XXX: Story Title - BLOCKED

- What was attempted
- What's blocking progress
- Suggested resolution
-->

---

## 2026-11-01 17:11 - US-001: Generate data/mortality.csv - BLOCKED

- Implemented tools/generate-table.mjs per the stated formula q(x) = min(1, A + B*exp(C*x)), with fixed q(0) and q(120)=1, and generated data/mortality.csv.
- Verified: 123 lines (comment, header, 121 rows); row 0 is 0.00400000 / 0.00350000; row 120 is 1.00000000 / 1.00000000; two runs are byte-identical (cmp); q(x) is non-decreasing for x=1..119 for both sexes.
- Blocking discrepancy: the acceptance criterion says male age 80 should be 0.06196 "(0.0002 + 0.00003 * exp(7.6))", but that expression evaluates to 0.06014588. The formula and the number cannot both hold. Story left passes: false.
- Suggested resolution: a human decides whether the constants (e.g. B or C) or the expected value 0.06196 is the intended one. Once decided, update the PRD text, regenerate the CSV, and rerun the checks. data/reference.json is not yet created (US-004), so no off-limits file was touched.
