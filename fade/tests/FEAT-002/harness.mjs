// Fake-DOM harness for FEAT-002 regression tests.
// Provides just enough of document/window/canvas/performance/requestAnimationFrame
// for src/app.mjs to run under Node, with a controllable clock.
//
//   const h = await loadApp();         // imports src/app.mjs against the fake DOM, waits for init
//   h.text('age')                      // textContent of #age
//   h.click('play'); h.advance(250)    // advance the clock 250 ms and run pending rAF callbacks
//   h.setValue('startAge', '60')       // set a control value and fire 'change'
//   h.ctx('chart').calls               // recorded 2D-context calls for a canvas

import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import path from 'node:path';

const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '../../..');

function makeCtx() {
  const calls = [];
  const ctx = { calls };
  const methods = ['fillRect', 'clearRect', 'beginPath', 'moveTo', 'lineTo', 'stroke', 'fill', 'arc', 'fillText'];
  for (const m of methods) ctx[m] = (...args) => calls.push({ m, args, lineWidth: ctx.lineWidth, strokeStyle: ctx.strokeStyle, fillStyle: ctx.fillStyle });
  return ctx;
}

function makeEl(id, attrs = {}) {
  const ctx = makeCtx();
  const el = {
    id,
    tagName: attrs.tag || 'div',
    textContent: '',
    value: attrs.value ?? '',
    hidden: false,
    width: attrs.width ?? 800,
    height: attrs.height ?? 400,
    clientWidth: attrs.width ?? 800,
    clientHeight: attrs.height ?? 400,
    offsetWidth: 100,
    listeners: {},
    classList: { _s: new Set(), add(c) { this._s.add(c); }, remove(c) { this._s.delete(c); }, contains(c) { return this._s.has(c); } },
    addEventListener(type, fn) { (this.listeners[type] ||= []).push(fn); },
    dispatch(type) { for (const fn of this.listeners[type] || []) fn({ type, target: this }); },
    getContext() { return ctx; },
    _ctx: ctx,
  };
  return el;
}

export async function loadApp({ chartWidth = 800, chartHeight = 400 } = {}) {
  const els = {
    sex: makeEl('sex', { value: 'male' }),
    startAge: makeEl('startAge', { value: '0' }),
    improvement: makeEl('improvement', { value: '0' }),
    improvementValue: makeEl('improvementValue'),
    legend: makeEl('legend'),
    age: makeEl('age'),
    alive: makeEl('alive'),
    pct: makeEl('pct'),
    aliveImproved: makeEl('aliveImproved'),
    extra: makeEl('extra'),
    play: makeEl('play'),
    pause: makeEl('pause'),
    reset: makeEl('reset'),
    chart: makeEl('chart', { tag: 'canvas', width: chartWidth, height: chartHeight }),
    field: makeEl('field', { tag: 'canvas', width: 600, height: 600 }),
    title: makeEl('title'),
  };

  let now = 0;
  let rafQueue = [];
  const windowListeners = {};

  globalThis.document = { getElementById: (id) => els[id] || null };
  globalThis.window = {
    addEventListener(type, fn) { (windowListeners[type] ||= []).push(fn); },
    dispatch(type) { for (const fn of windowListeners[type] || []) fn({ type }); },
  };
  globalThis.performance = { now: () => now };
  globalThis.requestAnimationFrame = (fn) => { const id = rafQueue.length + 1; rafQueue.push({ id, fn }); return id; };
  globalThis.cancelAnimationFrame = (id) => { rafQueue = rafQueue.filter((r) => r.id !== id); };
  globalThis.setTimeout = (fn) => { fn(); return 1; };
  globalThis.clearTimeout = () => {};
  const csv = readFileSync(path.join(ROOT, 'data/mortality.csv'), 'utf8');
  globalThis.fetch = async (url) => {
    if (!String(url).startsWith('data/mortality.csv')) return { ok: false, status: 404 };
    return { ok: true, status: 200, text: async () => csv };
  };

  await import(pathToFileURL(path.join(ROOT, 'src/app.mjs')).href);
  // init() is async; let it settle.
  for (let i = 0; i < 10; i++) await new Promise((r) => setImmediate(r));

  function runFrames() {
    // Run only callbacks queued before this frame; new ones wait for the next advance.
    const pending = rafQueue;
    rafQueue = [];
    for (const { fn } of pending) fn(now);
  }

  return {
    els,
    text: (id) => els[id].textContent,
    click: (id) => els[id].dispatch('click'),
    setValue: (id, v) => { els[id].value = String(v); els[id].dispatch('change'); },
    // Advance the fake clock by ms in `step` increments, running a frame after each.
    advance(ms, step = 16) {
      let left = ms;
      while (left > 0) {
        const d = Math.min(step, left);
        now += d;
        left -= d;
        runFrames();
      }
    },
    frame: () => runFrames(),
    resize(w, h) { els.chart.clientWidth = w; els.chart.clientHeight = h; window.dispatch('resize'); },
    ctx: (id) => els[id]._ctx,
    now: () => now,
    ROOT,
  };
}

export function fail(msg, expected, actual) {
  console.log(`FAIL: ${msg}`);
  if (expected !== undefined) console.log(`Expected: ${expected}`);
  if (actual !== undefined) console.log(`Actual: ${actual}`);
  process.exit(1);
}
