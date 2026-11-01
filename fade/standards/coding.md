# Coding standard

- ES modules only. Files end in `.mjs`.
- `src/engine/` has no DOM, no `window`, no `document`, no `Math.random`.
- `src/particles.mjs` may use `Math.random` for particle placement only. The number of visible particles at an age is `round(1000 * lx / l0)`, taken from the engine.
- Small functions, one job each. No class hierarchies.
- No external scripts, fonts or stylesheets fetched from the network. The page must work offline on a conference laptop.
- Comments say why, not what.
