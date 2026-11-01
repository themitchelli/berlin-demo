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

## 2026-11-01 - Headless Chrome --dump-dom does not pump requestAnimationFrame
**Source:** PRD-ID FEAT-002 US-002

- **What:** `chrome --headless=new --dump-dom` with `--virtual-time-budget` fires a requestAnimationFrame callback once and then stops, so any rAF-driven animation looks frozen. Also, `timeout` is not installed on macOS, so `timeout ... chrome` silently produces no output.
- **Why it matters:** To check rAF-driven behaviour headlessly, test a scratch copy with `window.requestAnimationFrame = cb => setTimeout(() => cb(performance.now()), 16)` injected before the module loads. Keep the polyfill out of the committed code. Run the browser checks with a plain command, not `timeout`.

## 2026-11-01 - Drive button clicks headlessly with an injected script in a scratch copy
**Source:** PRD-ID FEAT-005 US-002

- **What:** Under `--virtual-time-budget`, timers run, so a scratch copy of index.html with an inline script can call `getElementById('play').click()` after a delay and then record DOM state. `--dump-dom` only returns the final DOM, so accumulate the readings into `document.title` (joined with ` | `) to read every step from the one dump. Use a budget around 20000 ms for a 3-second sequence. A stale `python3 -m http.server` on the same port can serve an old directory, so check `lsof -nP -iTCP:<port>` before trusting a probe.
- **Why it matters:** Earlier notes say headless cannot press Play. Button clicks and state changes can be checked this way; only rAF-driven motion and visual transitions still need a person.
