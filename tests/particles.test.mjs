import { test } from 'node:test';
import assert from 'node:assert/strict';
import { visibleCount, update, drawRadius } from '../src/particles.mjs';

test('visibleCount maps the engine count onto 1,000 particles', () => {
  assert.equal(visibleCount(1000000, 1000000), 1000);
  assert.equal(visibleCount(0, 1000000), 0);
  assert.equal(visibleCount(500500, 1000000), 501);
});

// A stub context records calls so the test can run without a canvas.
function stubField(count) {
  const ctx = {
    clearRect() {},
    beginPath() {},
    arc() {},
    fill() {},
  };
  const particles = [];
  for (let i = 0; i < count; i++) {
    particles.push({ x: i, y: i, r: 2, phase: 0, alive: true, fade: 1, originX: i, originY: i });
  }
  return { ctx, width: 100, height: 100, particles };
}

test('update keeps exactly aliveCount particles alive, killing from the end of the array', () => {
  const field = stubField(10);
  update(field, 6, 16);
  const alive = field.particles.map((p) => p.alive);
  assert.deepEqual(alive, [true, true, true, true, true, true, false, false, false, false]);
});

test('dead particles fade over 400 ms and reach zero', () => {
  const field = stubField(4);
  update(field, 2, 0);
  assert.equal(field.particles[3].fade, 1);
  update(field, 2, 200);
  assert.ok(Math.abs(field.particles[3].fade - 0.5) < 1e-9);
  update(field, 2, 400);
  assert.equal(field.particles[3].fade, 0);
  assert.equal(field.particles[0].fade, 1);
});

test('dead particles shrink to 60% of radius as they fade; living ones keep full radius', () => {
  const field = stubField(2);
  field.particles.forEach((p) => (p.r = 2));
  update(field, 1, 0);
  assert.equal(drawRadius(field.particles[0]), 2);
  update(field, 1, 200);
  assert.ok(Math.abs(drawRadius(field.particles[1]) - 2 * 0.8) < 1e-9);
  update(field, 1, 200);
  assert.ok(Math.abs(drawRadius(field.particles[1]) - 2 * 0.6) < 1e-9);
  assert.equal(drawRadius(field.particles[0]), 2);
});

test('reset-style restore: aliveCount back to full sets every particle alive with fade 1 in one update', () => {
  const field = stubField(4);
  update(field, 0, 400);
  assert.ok(field.particles.every((p) => p.fade === 0 && !p.alive));
  update(field, 4, 16);
  assert.ok(field.particles.every((p) => p.alive && p.fade === 1));
});

test('aliveCount is clamped to the particle count', () => {
  const field = stubField(5);
  update(field, 999, 16);
  assert.ok(field.particles.every((p) => p.alive));
  update(field, -3, 16);
  assert.ok(field.particles.every((p) => !p.alive));
});
