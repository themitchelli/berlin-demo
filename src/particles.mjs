// Particle field. DISPLAY ONLY: it draws a picture of the engine's survivor counts.
// It never calculates mortality, and the only randomness is the starting layout in createField.
//
// visibleCount(lx, l0, total)  -> how many particles should be alive (pure).
// createField(canvas, total)   -> field object holding the particles and a 2D context.
// update(field, aliveCount, dtMs) -> kills particles to match aliveCount, drifts and draws.

const FADE_MS = 400;
const DRIFT_AMPLITUDE = 0.6; // pixels; the sine-based drift stays within this of the start point
const DRIFT_RATE = 0.0008; // radians per millisecond
const GLOW_COLOUR = '#7dd3fc';
const PARTICLE_COLOUR = '#e0f2fe';
const RADIUS_MIN = 1.5;
const RADIUS_MAX = 3;

export function visibleCount(lx, l0, total = 1000) {
  return Math.round((total * lx) / l0);
}

export function createField(canvas, total = 1000) {
  const width = canvas.width;
  const height = canvas.height;
  const particles = [];
  for (let i = 0; i < total; i++) {
    const x = Math.random() * width;
    const y = Math.random() * height;
    particles.push({
      x,
      y,
      r: RADIUS_MIN + Math.random() * (RADIUS_MAX - RADIUS_MIN),
      phase: Math.random() * Math.PI * 2,
      alive: true,
      fade: 1,
      // Drift is an offset from the start point, so particles stay near where they were laid out.
      originX: x,
      originY: y,
    });
  }
  return { canvas, ctx: canvas.getContext('2d'), width, height, particles };
}

// Particles at index < aliveCount are alive; the rest die, so deaths always run from the end of the array.
export function update(field, aliveCount, dtMs) {
  const { particles, ctx, width, height } = field;
  const alive = Math.max(0, Math.min(particles.length, aliveCount));
  const dt = Math.max(0, dtMs);

  for (let i = 0; i < particles.length; i++) {
    const p = particles[i];
    p.alive = i < alive;
    if (p.alive) {
      p.fade = 1;
    } else {
      p.fade = Math.max(0, p.fade - dt / FADE_MS);
    }

    p.phase += dt * DRIFT_RATE;
    p.x = p.originX + DRIFT_AMPLITUDE * Math.sin(p.phase);
    p.y = p.originY + DRIFT_AMPLITUDE * Math.cos(p.phase * 0.7);
  }

  if (!ctx) return;
  ctx.clearRect(0, 0, width, height);
  ctx.shadowBlur = 8;
  ctx.shadowColor = GLOW_COLOUR;
  ctx.fillStyle = PARTICLE_COLOUR;
  for (const p of particles) {
    if (p.fade <= 0) continue;
    ctx.globalAlpha = p.fade;
    ctx.beginPath();
    ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
    ctx.fill();
  }
  ctx.globalAlpha = 1;
}
