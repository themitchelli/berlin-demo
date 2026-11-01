<!-- FADE learned.md v0.3.1 -->

# Learned

Discoveries and insights from development sessions. Append-only.

<!--
Entry format (append new entries below the line):

## YYYY-MM-DD - Discovery Title
**Source:** PRD-ID US-XXX

- **What:** Brief description of the discovery
- **Why it matters:** How this helps future work

Only add learnings that are:
- Reusable (not story-specific details)
- Non-obvious (things a future session wouldn't know)
- Actionable (helps avoid mistakes or speeds up work)
-->

---

## 2026-11-01 - `node --test tests/` fails on Node 21+
**Source:** PRD-ID FEAT-001 US-002

- **What:** On Node 21 and later, `node --test <dir>` is treated as a file path and fails with MODULE_NOT_FOUND. The runner takes glob patterns. On Node 20 the directory form works.
- **Why it matters:** Run `node --test tests/*.test.mjs` on Node 21+. Do not mark a story passing on the basis of the directory form failing silently.
