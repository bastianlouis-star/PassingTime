'use strict';
// PASSING TIME - an immortal, alone, with nothing but time.
// Everything is drawn procedurally on a 320x180 canvas (no external assets).

const W = 320, H = 180;
const cv = document.getElementById('c');
const g = cv.getContext('2d');
g.imageSmoothingEnabled = false;
const $ = id => document.getElementById(id);

/* ------------------------------------------------------------------ DATA */

const DAY = 1 / 365.25, HOUR = DAY / 24;

// years = in-game duration, sec = real seconds the time-lapse lasts,
// decay = how much of its charm the activity keeps after each use.
const ERAS = [
  { name: 'The Room', intro: 'You have lost count of the days. You do not remember the last time you were tired.',
    acts: [
      { id: 'read',   name: 'Read a book',                 dur: '3 days',  years: 3 * DAY,   sec: 4, decay: .6, vis: 'book',  line: 'The ending was good. You knew it would be. You have read it before.' },
      { id: 'movie',  name: 'Watch a movie',               dur: '2 hours', years: 2 * HOUR,  sec: 4, decay: .6, vis: 'tv',    line: 'The credits roll. You stay for all of them.' },
      { id: 'chess',  name: 'Play chess against yourself', dur: '1 day',   years: DAY,       sec: 4, decay: .6, vis: 'chess', line: 'A draw. Again. You shake your own hand.' },
      { id: 'tiles',  name: 'Count the ceiling tiles',     dur: '1 week',  years: 7 * DAY,   sec: 4, decay: .6, vis: 'none',  line: '1,204. You counted twice. It was 1,204 both times.' },
    ] },
  { name: 'The House', intro: 'The room is too small for so much time. You open the door.',
    acts: [
      { id: 'write',  name: 'Write a book',                dur: '2 years',  years: 2,   sec: 5, decay: .55, vis: 'write',  line: 'Four hundred pages. No one will read it. You read it anyway.' },
      { id: 'garden', name: 'Tend a garden',               dur: '1 year',   years: 1,   sec: 5, decay: .55, vis: 'garden', line: 'The tomatoes are perfect. Nobody to give them to.' },
      { id: 'piano',  name: 'Learn the piano',             dur: '8 years',  years: 8,   sec: 5, decay: .55, vis: 'piano',  line: 'You play the same sonata until it plays you.' },
      { id: 'lang',   name: 'Learn a new language',        dur: '30 years', years: 30,  sec: 6, decay: .55, vis: 'lang',   line: 'You can now be lonely in nine languages.' },
    ] },
  { name: 'The Decades', intro: 'Years stop having names. The seasons start to blur.',
    acts: [
      { id: 'walk',   name: 'Walk across the world',       dur: '15 years',  years: 15,  sec: 6, decay: .5, vis: 'walk',  line: 'You reach the sea again. You are not sure which one.' },
      { id: 'paint',  name: 'Paint a thousand canvases',   dur: '60 years',  years: 60,  sec: 6, decay: .5, vis: 'paint', line: 'Every one is a window. None of them has a person in it.' },
      { id: 'build',  name: 'Build a house with your hands', dur: '25 years', years: 25, sec: 6, decay: .5, vis: 'build', line: 'It stands. It will outlast you, and you will outlast it.' },
      { id: 'learn',  name: 'Study every science',         dur: '120 years', years: 120, sec: 7, decay: .5, vis: 'learn', line: 'You understand how it all works. It does not help.' },
    ] },
  { name: 'The Centuries', intro: 'You stop making things. You start watching them.',
    acts: [
      { id: 'forest', name: 'Raise a forest from a seed',     dur: '400 years', years: 400, sec: 7, decay: .4, vis: 'forest',  line: 'The oaks are older than any language you speak.' },
      { id: 'village',name: 'Watch a village become a city',  dur: '600 years', years: 600, sec: 7, decay: .4, vis: 'village', line: 'They built walls, then streets, then forgot why.' },
      { id: 'family', name: 'Follow one family through time', dur: '300 years', years: 300, sec: 7, decay: .4, vis: 'family',  line: 'You knew a grandmother and, later, her great-great-grandson. Same laugh.' },
    ] },
  { name: 'The Millennia', intro: 'Your own memories feel like someone else\'s story.',
    acts: [
      { id: 'rise',   name: 'Watch an empire rise',           dur: '2,000 years',  years: 2000,  sec: 8, decay: .3, vis: 'rise',    line: 'They carved their names in marble. You can still read them.' },
      { id: 'fall',   name: 'Watch an empire crumble',               dur: '1,500 years',  years: 1500,  sec: 8, decay: .3, vis: 'fall',    line: 'Vines in the senate. A goat on the throne.' },
      { id: 'glacier',name: 'Watch a glacier carve a valley', dur: '50,000 years', years: 5e4,   sec: 8, decay: .3, vis: 'glacier', line: 'Slower than anything you have ever watched. You loved it.' },
    ] },
  { name: 'Deep Time', intro: 'Even mountains begin to look impatient.',
    acts: [
      { id: 'evolve', name: 'Watch a species evolve',         dur: '5 million years',   years: 5e6,   sec: 10, decay: .3, vis: 'evolve', line: 'Something looked up at the sky and wondered. You waved. It didn\'t see you.' },
      { id: 'drift',  name: 'Watch the continents drift',     dur: '100 million years', years: 1e8,   sec: 10, decay: .3, vis: 'drift',  line: 'The map you memorized is wrong again.' },
      { id: 'ice',    name: 'Watch the ice ages come and go', dur: '10 million years',  years: 1e7,   sec: 9,  decay: .3, vis: 'ice',    line: 'White, green, white, green. A slow breathing.' },
    ] },
  { name: 'Stars', intro: 'The Earth is a habit you can no longer afford.',
    acts: [
      { id: 'planet', name: 'Watch a planet form',            dur: '100 million years', years: 1e8,   sec: 11, decay: .2, vis: 'planet',  line: 'Dust, then rock, then a world. It has no one on it yet.' },
      { id: 'star',   name: 'Watch a sun live its life',      dur: '5 billion years',   years: 5e9,   sec: 11, decay: .2, vis: 'star',    line: 'It burned steadily, as if it had somewhere to be.' },
      { id: 'swallow',name: 'Watch your world swallowed by its sun', dur: '1 billion years', years: 1e9, sec: 13, decay: .2, vis: 'swallow', line: 'It was beautiful, for a moment. Then it was inside the light.' },
    ] },
  { name: 'The Long Dark', intro: 'There are fewer and fewer things left to look at.',
    acts: [
      { id: 'stars',  name: 'Watch the last stars burn out',       dur: '100 trillion years', years: 1e14,  sec: 13, decay: .2, vis: 'stars',      line: 'One by one. You say goodnight to each of them.' },
      { id: 'holes',  name: 'Watch the black holes evaporate',     dur: '10^100 years',       years: 1e100, sec: 13, decay: .2, vis: 'blackholes', line: 'Even the darkness runs out of itself.' },
      { id: 'photon', name: 'Watch the last light fade',           dur: '...',                years: 1e106, sec: 12, decay: .2, vis: 'photon',     line: 'A single photon, crossing an empty universe. Then not even that.' },
    ] },
  { name: 'Nothing', intro: 'There is nothing left to watch. Only you.',
    acts: [
      { id: 'letgo',  name: 'Let go',                          dur: 'forever', years: 1e200, sec: 16, decay: 0, vis: 'dissolve', line: '' },
    ] },
];

/* ----------------------------------------------------------------- STATE */

const SAVE_KEY = 'passing-time-v1';
let S = load();
let run = null;          // { act, prog }
let lastVis = 'room', lastP = 1;
let ta = 0;              // animation clock (accelerates while time flows)
let fade = 1;            // black overlay, fades in at start/transition
let fast = false;

function fresh() { return { era: 0, fresh: {}, elapsed: 0, ennui: 35, ended: false }; }
function load() {
  try { const s = JSON.parse(localStorage.getItem(SAVE_KEY)); if (s && s.era >= 0) return Object.assign(fresh(), s); } catch (e) {}
  return fresh();
}
function save() { try { localStorage.setItem(SAVE_KEY, JSON.stringify(S)); } catch (e) {} }
const era = () => ERAS[S.era];
const fr = a => (S.fresh[a.id] === undefined ? 1 : S.fresh[a.id]);

/* ----------------------------------------------------------------- UTILS */

const clamp = (v, a = 0, b = 1) => Math.max(a, Math.min(b, v));
const rnd = n => { const s = Math.sin(n * 127.1 + 311.7) * 43758.5453; return s - Math.floor(s); };
const hc = {};
const rgb = h => hc[h] || (hc[h] = [1, 3, 5].map(i => parseInt(h.slice(i, i + 2), 16)));
const mix = (a, b, t) => { t = clamp(t); const A = rgb(a), B = rgb(b); return `rgb(${A.map((v, i) => Math.round(v + (B[i] - v) * t)).join(',')})`; };
function R(c, x, y, w, h) { g.fillStyle = c; g.fillRect(Math.round(x), Math.round(y), Math.round(w), Math.round(h)); }
function disc(c, cx, cy, r) {
  g.fillStyle = c;
  for (let dy = -Math.floor(r); dy <= r; dy++) {
    const w = Math.sqrt(Math.max(0, r * r - dy * dy));
    g.fillRect(Math.round(cx - w), Math.round(cy + dy), Math.round(w * 2), 1);
  }
}
const skyCol = ph => mix('#080c20', '#6aa8dc', (Math.sin(ph * Math.PI * 2 - 1.2) + 1) / 2);
const nightness = ph => 1 - (Math.sin(ph * Math.PI * 2 - 1.2) + 1) / 2;
const STARS = Array.from({ length: 170 }, (_, i) => ({ x: rnd(i) * W, y: rnd(i + 500) * H, k: rnd(i + 900), ph: rnd(i + 1300) * 6 }));
function stars(alive = 1, ymax = H, a = 1) {
  for (const s of STARS) {
    if (s.k > alive || s.y > ymax) continue;
    g.globalAlpha = a * (0.4 + 0.6 * (0.5 + 0.5 * Math.sin(ta * 2 + s.ph)));
    R('#fff', s.x, s.y, 1, 1);
  }
  g.globalAlpha = 1;
}

function sup(n) { return String(n).replace(/\d/g, d => '⁰¹²³⁴⁵⁶⁷⁸⁹'[d]); }
function fmtClock(y) {
  if (S.ended) return '∞';
  if (y < 1) return 'Day ' + (Math.floor(y * 365.25) + 1).toLocaleString();
  if (y < 10000) return 'Year ' + Math.floor(y).toLocaleString() + ', day ' + (Math.floor((y % 1) * 365.25) + 1);
  if (y < 1e6) return Math.floor(y).toLocaleString() + ' years';
  if (y < 1e9) return (y / 1e6).toFixed(1) + ' million years';
  if (y < 1e12) return (y / 1e9).toFixed(2) + ' billion years';
  const e = Math.floor(Math.log10(y));
  return (y / Math.pow(10, e)).toFixed(2) + ' × 10' + sup(e) + ' years';
}
// Long durations are interpolated on a log scale so the counter visibly races through exponents.
const timeAt = (years, p) => years < 1e4 ? years * p : Math.pow(years, p) - 1 + p;

/* ---------------------------------------------------------------- SPRITE */

const SPR = [
  '..hhhh..', '.hhhhhh.', '.hssssh.', '.hesseh.', '.hssssh.', '..ssss..',
  '.cccccc.', 'cccccccc', 'cccccccc', 'cccccccc', '.cccccc.',
  '.pp..pp.', '.pp..pp.', '.pp..pp.', '.bb..bb.',
];
// (x, y) = bottom-centre. opt: beard rows, gray hair, dissolve 0..1, dim 0..1
function drawChar(x, y, s, opt = {}) {
  const hair = opt.gray ? '#b8b8c0' : '#4a3020';
  const pal = { h: hair, s: '#e0b890', e: '#1a1a1a', c: '#5a6a9a', p: '#3a3a4a', b: '#2a1f18', w: '#cfcfd4' };
  const dis = opt.dissolve || 0;
  const ox = x - 4 * s, oy = y - SPR.length * s;
  const beard = opt.beard || 0;
  for (let j = 0; j < SPR.length; j++) for (let i = 0; i < 8; i++) {
    let ch = SPR[j][i];
    if (beard && j >= 4 && j < 4 + beard && i >= 2 && i <= 5 && ch !== 'e') ch = 'w';
    if (beard && j >= 4 && j < 4 + beard && (i === 1 || i === 6) && j === 4) ch = SPR[j][i] === '.' ? '.' : ch;
    if (ch === '.') continue;
    const k = rnd(i * 31 + j * 7);
    let a = 1, dx = 0, dy = 0;
    if (dis > 0) {
      if (dis > k) a = clamp(1 - (dis - k) * 5);
      dx = (k - .5) * dis * 40; dy = -dis * (6 + k * 30);
      if (a <= 0) continue;
    }
    g.globalAlpha = a * (1 - (opt.dim || 0));
    R(pal[ch], ox + i * s + dx, oy + j * s + dy, s, s);
  }
  g.globalAlpha = 1;
}
const beardFor = e => [0, 1, 2, 3, 4, 4, 4, 4, 4][e];

/* ---------------------------------------------------------------- SCENES */

const hero = (x, y, s = 3, o = {}) => drawChar(x, y, s, Object.assign({ beard: beardFor(S.era), gray: S.era >= 3 }, o));
const isVis = (v) => lastVis === v;

function sceneRoom(p, running) {
  R('#1f2538', 0, 0, W, H);
  R('#2a3149', 0, 0, W, 6);
  R('#5a3d2b', 0, 135, W, 45); R('#46301f', 0, 135, W, 2);
  // window
  R('#8a7a5a', 228, 24, 60, 52); R('#0c1024', 232, 28, 52, 44);
  for (let i = 0; i < 14; i++) R('#fff', 234 + rnd(i) * 48, 30 + rnd(i + 9) * 40, 1, 1);
  disc('#e8e4c0', 270, 40, 5); disc('#0c1024', 273, 38, 4);
  R('#8a7a5a', 257, 28, 2, 44); R('#8a7a5a', 232, 49, 52, 2);
  // shelf
  R('#4a3220', 16, 38, 60, 98);
  for (let r = 0; r < 4; r++) {
    R('#2e1f14', 18, 40 + r * 24, 56, 22);
    for (let b = 0; b < 12; b++) { const h = 12 + rnd(b + r * 20) * 9; R(['#a04040', '#3a6a9a', '#6a9a4a', '#c0a040', '#7a4a9a'][Math.floor(rnd(b * 3 + r) * 5)], 20 + b * 4.5, 62 + r * 24 - h, 3, h); }
  }
  // tv
  R('#3a2a1d', 96, 114, 58, 22);
  R('#111', 90, 78, 70, 38);
  const on = isVis('tv') && (running || lastP < 1);
  if (on) {
    const f = Math.floor(ta * 8);
    R(['#4a7ad0', '#d07a4a', '#4ad07a', '#d04a7a'][f % 4], 94, 82, 62, 30);
    R('#ffffff', 100 + (f * 7) % 40, 90 + (f * 3) % 12, 8, 8);
    g.globalAlpha = .12; R('#aaccff', 60, 70, 130, 70); g.globalAlpha = 1;
  } else R('#1a1e28', 94, 82, 62, 30);
  // chess table
  R('#6b4a30', 226, 112, 62, 5); R('#5a3d28', 230, 117, 4, 18); R('#5a3d28', 280, 117, 4, 18);
  for (let r = 0; r < 2; r++) for (let c = 0; c < 8; c++) R((r + c) % 2 ? '#2a1a10' : '#d8c8a0', 234 + c * 6, 102 + r * 5, 6, 5);
  const playing = isVis('chess') && running;
  for (let i = 0; i < 6; i++) {
    const m = playing ? Math.floor(ta * 2 + i) % 8 : i + 1;
    R(i % 2 ? '#111' : '#fff', 235 + m * 6, 98 + (i % 2) * 5, 3, 5);
  }
  // hero
  hero(190, 138, 3);
  if (isVis('book') && (running || lastP < 1)) { R('#a04040', 188, 108, 14, 9); R('#e8e0c8', 190, 110, 10, 5); }
  if (isVis('tiles') && running) { g.globalAlpha = .6; R('#fff', 186 + Math.sin(ta * 3) * 6, 88, 2, 2); g.globalAlpha = 1; }
}

function sceneGarden(p, running) {
  const day = (ta * (running ? .35 : .05)) % 1;
  R(skyCol(day), 0, 0, W, 130);
  stars(nightness(day), 120, nightness(day));
  disc(mix('#f8e8a0', '#f8e8a0', 0), 60 + day * 200, 30 + Math.abs(Math.sin(day * Math.PI)) * -10 + 25, 8);
  R('#2d5a3a', 0, 118, W, 62); R('#3a7048', 0, 118, W, 3);
  // house
  R('#8a6a50', 14, 78, 74, 50);
  for (let i = 0; i < 6; i++) R('#a04a3a', 8 + i * 2, 70 + i * 2, 86 - i * 4, 2);
  R('#6a3a2a', 38, 100, 14, 28);
  R(nightness(day) > .4 ? '#f8d070' : '#9ac0e0', 62, 92, 14, 12);
  // flowers
  const gar = isVis('garden');
  for (let i = 0; i < 22; i++) {
    const h = 3 + (gar ? p : 1) * 13 * (.5 + rnd(i));
    const x = 190 + i * 5.5, y = 150 + (i % 3) * 5;
    R('#2a6a2a', x, y - h, 1, h);
    R(['#e04a6a', '#e0c04a', '#c04ae0', '#fff'][i % 4], x - 1, y - h - 2, 3, 3);
  }
  hero(140, 142, 3);
  if (isVis('write')) { R('#6b4a30', 158, 128, 30, 4); R('#5a3d28', 160, 132, 3, 12); R('#5a3d28', 183, 132, 3, 12);
    R('#f4f0e0', 166, 128 - p * 14, 14, p * 14 + 1); }
  if (isVis('piano')) { R('#1a1a1a', 156, 112, 38, 28); R('#f4f4f4', 158, 124, 34, 6);
    const k = running ? Math.floor(ta * 10) % 12 : -1; for (let i = 0; i < 11; i++) R(i === k ? '#a0a0a0' : '#ddd', 158 + i * 3 + 2, 124, 1, 6);
    if (running) for (let i = 0; i < 3; i++) { g.globalAlpha = .7; R('#e0b060', 160 + ((ta * 20 + i * 30) % 34), 108 - ((ta * 15 + i * 9) % 20), 2, 2); g.globalAlpha = 1; } }
  if (isVis('lang') && running) for (let i = 0; i < 7; i++) { const t = (ta * .6 + i / 7) % 1;
    g.globalAlpha = 1 - t; R(['#e04a6a', '#4ae0a0', '#e0c04a', '#4a9ae0'][i % 4], 150 + Math.sin(i * 2) * 30, 100 - t * 40, 5 + (i % 3) * 3, 3); g.globalAlpha = 1; }
}

function mountains(off, yBase, amp, col, seed) {
  for (let x = 0; x < W; x += 2) {
    const wx = x + off;
    const h = amp * (.5 + .5 * Math.sin(wx * .02 + seed) * Math.cos(wx * .007 + seed * 2)) + amp * .3 * rnd(Math.floor(wx / 6) + seed);
    R(col, x, yBase - h, 2, h + 60);
  }
}

function sceneHill(p, running) {
  const day = (ta * (running ? .6 : .05)) % 1;
  R(skyCol(day), 0, 0, W, 150);
  stars(nightness(day), 110, nightness(day));
  const sx = 30 + day * 260; disc('#f8e8a0', sx, 90 - Math.sin(day * Math.PI) * 55, 9);
  const walk = isVis('walk') && running;
  const sp = walk ? ta * 40 : ta * 3;
  mountains(sp * .2, 125, 40, mix('#1a2a4a', '#4a5a7a', 1 - nightness(day)), 3);
  mountains(sp * .5, 135, 28, '#2a4a3a', 8);
  R('#2d5a3a', 0, 140, W, 40); R('#3a7048', 0, 140, W, 3);
  hero(46, 146, 3);
  const bob = walk ? Math.sin(ta * 12) * 1 : 0;
  if (isVis('paint')) {
    R('#6b4a30', 80, 118, 2, 28); R('#6b4a30', 96, 118, 2, 28); R('#f4f0e0', 82, 110, 14, 16);
    R(['#e04a6a', '#4a9ae0', '#e0c04a'][Math.floor(ta * 4) % 3], 84, 112, 4, 4);
    const n = Math.floor(p * 22); for (let i = 0; i < n; i++) R(['#e04a6a', '#4a9ae0', '#e0c04a', '#4ae0a0'][i % 4], 130 + (i % 9) * 16, 100 + Math.floor(i / 9) * 14, 12, 10);
  }
  if (isVis('build')) { const h = p * 40; R('#8a6a50', 160, 146 - h, 60, h); if (p > .5) for (let i = 0; i < 6; i++) R('#a04a3a', 154 + i * 2, 146 - h - 2 - i * 2 + 4, 72 - i * 4, 2); }
  if (isVis('learn') && running) for (let i = 0; i < 6; i++) { const a = ta * 2 + i; R(['#a04040', '#3a6a9a', '#6a9a4a'][i % 3], 46 + Math.cos(a) * 24, 100 + Math.sin(a) * 8, 6, 8); }
  void bob;
}

function sceneCity(p, running) {
  const vis = lastVis;
  const day = (ta * (running ? .9 : .05)) % 1;
  R(skyCol(day), 0, 0, W, 150);
  stars(nightness(day), 120, nightness(day));
  disc('#f8e8a0', 30 + day * 260, 90 - Math.sin(day * Math.PI) * 60, 8);
  mountains(0, 130, 30, '#2a3a52', 5);
  const night = nightness(day);
  R('#2d5a3a', 0, 142, W, 38);
  if (vis === 'glacier') {
    for (let x = 80; x < W; x++) {
      const d = clamp(1 - Math.abs(x - 210) / 110);
      const top = 142 - 20 + p * 30 * d + (1 - d) * -10 - 10 * (1 - p) * d;
      R('#5a5a64', x, top, 1, 60);
      if (x > 100) { const ice = 8 + 6 * Math.sin(x * .2 + ta * .5); R('#d8ecf8', x, top - ice * (1 - p * .6), 1, ice * (1 - p * .6) + 2); }
    }
    g.globalAlpha = .3; R('#fff', 80, 100, W - 80, 20); g.globalAlpha = 1;
  } else if (vis === 'forest') {
    for (let i = 0; i < 20; i++) {
      const h = (4 + rnd(i) * 22) * clamp(p * 1.4 - rnd(i + 3) * .4);
      const x = 100 + i * 10 + rnd(i + 7) * 4;
      R('#4a3220', x, 146 - h * .3, 2, h * .3);
      for (let k = 0; k < 3; k++) R(mix('#1f4a2a', '#3a7a3a', k / 3), x - (3 - k) * 1.5 + 1, 146 - h * .3 - (k + 1) * h * .25, (3 - k) * 3, h * .25 + 1);
    }
  } else if (vis === 'family') {
    const n = Math.ceil(p * 9);
    for (let i = 0; i < n; i++) {
      const x = 90 + i * 22, s = 1 + (i % 2);
      R('#e0b890', x, 128 - s * 2, 3, 3); R(['#a04a6a', '#4a6aa0', '#6aa04a'][i % 3], x, 131 - s * 2, 3, 6 + s); R('#3a3a4a', x, 137 + s - s * 2, 3, 3);
      if (i) R('#2a2f45', x - 18, 134, 16, 1);
    }
    R('#8a6a50', 270, 112, 36, 30); for (let i = 0; i < 5; i++) R('#a04a3a', 266 + i * 2, 106 + i * 2, 44 - i * 4, 2);
  } else {
    // buildings: village (small) / rise / fall
    const fall = vis === 'fall';
    const lvl = vis === 'village' ? p : fall ? 1 - p : p;
    const tall = vis === 'village' ? 34 : 60;
    for (let i = 0; i < 18; i++) {
      const bw = 8 + rnd(i) * 7, x = 80 + i * 13;
      let h = (4 + rnd(i + 11) * tall) * clamp(lvl * 1.5 - rnd(i + 2) * .5);
      if (fall) h *= 1 - rnd(i + 40) * (p * .6);
      if (h < 1) continue;
      const col = fall ? mix('#9a8a70', '#5a6a50', p) : '#8a7a68';
      R(col, x, 142 - h, bw, h);
      R(fall ? '#3a4a30' : '#a04a3a', x - 1, 141 - h, bw + 2, 2);
      if (vis === 'village' || !fall) for (let wy = 0; wy < h - 6; wy += 6) if (night > .35 && rnd(i * 9 + wy) > .35) R('#f8d070', x + 2, 142 - h + 5 + wy, 2, 2);
      if (fall) for (let v = 0; v < p * 6; v++) R('#2a6a2a', x + rnd(i + v) * bw, 142 - rnd(v + i * 3) * h, 1, 3 + p * 4);
    }
  }
  hero(46, 146, 3);
}

function creature(stage, x, y, f) {
  const t = Math.floor(ta * 6) % 2;
  if (stage === 0) { disc('#6aa0c0', x, y - 6, 3); R('#a0d0e0', x - 1, y - 7 + t, 2, 2); }
  else if (stage === 1) { R('#4a7aa0', x - 8, y - 8, 14, 6); R('#4a7aa0', x + 6, y - 11 + t, 4, 10); R('#fff', x - 6, y - 7, 1, 1); }
  else if (stage === 2) { R('#5a8a4a', x - 10, y - 8, 18, 5); R('#5a8a4a', x + 8, y - 11, 6, 6); R('#3a5a2a', x - 12, y - 6, 3, 2); R('#3a5a2a', x - 8, y - 3 + t, 2, 3); R('#3a5a2a', x + 4, y - 3 - t + 1, 2, 3); }
  else if (stage === 3) { R('#8a5a3a', x - 10, y - 14, 20, 8); R('#8a5a3a', x + 8, y - 18, 8, 7); R('#6a3a2a', x + 10, y - 21, 2, 3); for (const lx of [-8, -4, 4, 8]) R('#6a3a2a', x + lx, y - 6, 2, 6 + (lx > 0 ? t : 1 - t)); }
  else { drawChar(x, y, 2, { beard: 0, gray: false }); }
}

function sceneEvolve(p, running) {
  const vis = lastVis;
  if (vis === 'drift') {
    R('#2a5a8a', 0, 0, W, H);
    for (let c = 0; c < 4; c++) {
      const cx = 160 + (c - 1.5) * 60 + (c - 1.5) * p * 70;
      for (let x = -28; x < 28; x++) { const h = 14 * (1 - Math.abs(x) / 28) + rnd(x + c * 99) * 6; R(mix('#4a8a3a', '#8a7a4a', rnd(c)), cx + x, 100 - h, 1, h * 2); }
    }
    hero(46, 170, 2, { dim: 0 }); return;
  }
  if (vis === 'ice') {
    const cold = (1 - Math.cos(p * Math.PI * 6)) / 2;
    R(mix('#6aa8dc', '#cfe4f4', cold), 0, 0, W, 140);
    mountains(0, 125, 30, mix('#4a6a5a', '#e8f0f8', cold), 2);
    R(mix('#3a7048', '#f4f8fc', cold), 0, 140, W, 40);
    if (cold > .5) for (let i = 0; i < 30; i++) R('#fff', (rnd(i) * W + ta * 30) % W, (rnd(i + 5) * 140 + ta * 40) % 140, 1, 1);
    const mx = 200 + Math.sin(ta) * 10; R('#5a3a2a', mx - 10, 126, 20, 12); R('#5a3a2a', mx + 8, 120, 8, 10); R('#e8e0c8', mx + 14, 130, 2, 6);
    hero(46, 146, 3); return;
  }
  // evolve
  R('#7ab0d8', 0, 0, W, 120);
  R('#2d5a3a', 0, 130, W, 50); R('#2a5a8a', 0, 130, 120, 50);
  const stage = Math.min(4, Math.floor(p * 5));
  creature(stage, stage === 0 || stage === 1 ? 70 : 200 + Math.sin(ta * 2) * 20, stage < 2 ? 160 : 150, p);
  for (let i = 0; i < 4; i++) { const fl = Math.abs(p * 5 - (i + 1)); if (fl < .08) { g.globalAlpha = .5; R('#fff', 0, 0, W, H); g.globalAlpha = 1; } }
  hero(46, 140, 3, { dim: 0 });
}

function sceneSpace(p, running) {
  const vis = lastVis;
  R('#04050c', 0, 0, W, H);
  const cx = 230, cy = 88;
  if (vis === 'planet') {
    stars();
    for (let i = 0; i < 140; i++) {
      const a0 = rnd(i) * 6.28, r0 = 40 + rnd(i + 3) * 110;
      const q = clamp(p * 1.4 - rnd(i + 7) * .4);
      const r = r0 * (1 - q) + 2, a = a0 + ta * (1.5 + 30 / r0) * .4;
      R(q > .8 ? 'transparent' : '#a08a70', cx + Math.cos(a) * r, cy + Math.sin(a) * r * .6, 1, 1);
    }
    const pr = 4 + p * 26;
    disc(p < .5 ? mix('#e0602a', '#8a4a2a', p * 2) : mix('#8a4a2a', '#2a5aa0', (p - .5) * 2), cx, cy, pr);
    if (p > .7) { for (let i = 0; i < 6; i++) R('#3a8a3a', cx - pr * .6 + rnd(i) * pr, cy - pr * .6 + rnd(i + 4) * pr * 1.2, 4 + rnd(i) * 5, 3); }
  } else if (vis === 'star') {
    stars();
    const r = 22 + p * 8;
    g.globalAlpha = .15; disc('#ffe080', cx, cy, r + 5); g.globalAlpha = 1;
    disc(mix('#fff0a0', '#ffd060', p), cx, cy, r);
    const a = ta * 1.2; disc('#2a5aa0', cx - 90 + Math.cos(a) * 0, cy + 0, 0);
    const px = cx + Math.cos(a) * 85, py = cy + Math.sin(a) * 30;
    disc('#2a5aa0', px, py, 4); R('#3a8a3a', px - 2, py - 1, 3, 2);
  } else if (vis === 'swallow') {
    const r = 30 + p * p * 260;
    stars(1 - p);
    g.globalAlpha = .18; disc('#ff8030', cx, cy, r + 8); g.globalAlpha = 1;
    disc(mix('#ffcf50', '#d8402a', p * 1.4), cx, cy, r);
    const a = ta * 1.2, orb = 85;
    if (r < orb) { const px = cx + Math.cos(a) * orb, py = cy + Math.sin(a) * 30; disc('#2a5aa0', px, py, 4); R('#3a8a3a', px - 2, py - 1, 3, 2); }
    if (p > .88) { g.globalAlpha = clamp((p - .88) / .12); R('#fff', 0, 0, W, H); g.globalAlpha = 1; }
  }
  hero(46, 160, 3, { dim: vis === 'swallow' && p > .5 ? 0 : 0 });
  void running;
}

function sceneDark(p, running) {
  const vis = lastVis;
  R('#030308', 0, 0, W, H);
  if (vis === 'stars') stars(1 - p);
  else if (vis === 'blackholes') {
    for (let i = 0; i < 4; i++) {
      const x = 60 + rnd(i) * 200, y = 30 + rnd(i + 5) * 90, r = (3 + rnd(i + 2) * 8) * (1 - p);
      if (r < .5) continue;
      g.globalAlpha = .35 * (1 - p); disc('#e0a060', x, y, r + 3); g.globalAlpha = 1; disc('#000', x, y, r);
    }
    if (p > .5) { g.globalAlpha = (p - .5) * 2; }
    g.globalAlpha = 1;
  } else if (vis === 'photon') {
    const a = (1 - p) * (1 - p) * (.6 + .4 * Math.sin(ta * 20));
    g.globalAlpha = clamp(a); R('#fff', 40 + (1 - p) * 240, 90, 2, 1); g.globalAlpha = 1;
  }
  hero(46, 160, 3, { dim: .5 * (vis === 'photon' ? p : 0) });
  void running;
}

function sceneEnd(p) {
  R('#000', 0, 0, W, H);
  stars(0);
  hero(160, 140, 8, { dissolve: p });
}

function sceneFor() {
  switch (lastVis) {
    case 'room': case 'book': case 'tv': case 'chess': case 'tiles': return sceneRoom;
    case 'write': case 'garden': case 'piano': case 'lang': return sceneGarden;
    case 'walk': case 'paint': case 'build': case 'learn': return sceneHill;
    case 'forest': case 'village': case 'family': case 'rise': case 'fall': case 'glacier': return sceneCity;
    case 'evolve': case 'drift': case 'ice': return sceneEvolve;
    case 'planet': case 'star': case 'swallow': return sceneSpace;
    case 'stars': case 'blackholes': case 'photon': return sceneDark;
    case 'dissolve': return sceneEnd;
  }
  return sceneRoom;
}

/* -------------------------------------------------------------------- UI */

const el = { era: $('era'), clock: $('clock'), bar: $('bar'), log: $('log'), acts: $('acts'), ennuiLabel: $('ennuiLabel') };

function say(t) { el.log.textContent = t; }

function ennuiWord(e) {
  return e < 25 ? 'content' : e < 50 ? 'restless' : e < 75 ? 'bored' : e < 92 ? 'hollow' : 'unbearable';
}

function buildUI() {
  el.acts.innerHTML = '';
  if (S.ended) {
    const b = document.createElement('button'); b.id = 'next'; b.textContent = 'Begin again';
    b.onclick = reset; el.acts.appendChild(b); return;
  }
  const busy = !!run;
  for (const a of era().acts) {
    const b = document.createElement('button');
    b.disabled = busy;
    const f = fr(a);
    b.innerHTML = `${a.name}<small>${a.dur}${f < .5 ? ' · worn out' : ''}</small><div class="fresh"><i style="width:${Math.round(f * 100)}%"></i></div>`;
    b.onclick = () => start(a);
    el.acts.appendChild(b);
  }
  if (S.era < ERAS.length - 1 && era().acts.every(a => fr(a) < .5)) {
    const b = document.createElement('button'); b.id = 'next'; b.disabled = busy;
    b.textContent = 'Look for something longer →';
    b.onclick = nextEra; el.acts.appendChild(b);
  }
}

function start(a) {
  if (run) return;
  run = { act: a, prog: 0, base: S.elapsed };
  lastVis = a.vis; lastP = 0;
  say('');
  buildUI();
}

function finish() {
  const a = run.act;
  S.elapsed += a.years;
  S.fresh[a.id] = fr(a) * a.decay;
  S.ennui = Math.max(0, S.ennui - 55 * fr(a) / a.decay);
  lastP = 1;
  run = null;
  if (a.vis === 'dissolve') {
    S.ended = true;
    say('There is nothing left to do. There is nothing left.');
  } else say(a.line);
  save(); buildUI();
}

function nextEra() {
  S.era++;
  S.ennui = 30;
  lastVis = era().acts[0].vis; lastP = 0.5;
  fade = 1;
  say(era().intro);
  save(); buildUI();
}

function reset() {
  S = fresh(); run = null; lastVis = 'room'; lastP = 1; fade = 1;
  save(); say(era().intro); buildUI();
}

/* ------------------------------------------------------------------ LOOP */

let last = performance.now();
function frame(now) {
  const dt = Math.min(.1, (now - last) / 1000); last = now;
  const speed = fast ? 4 : 1;
  ta += dt * (run ? 5 : 1) * speed;
  if (run) {
    run.prog += dt * speed / run.act.sec;
    S.ennui = Math.max(0, S.ennui - dt * 6);
    if (run.prog >= 1) finish();
    else lastP = run.prog;
  } else S.ennui = Math.min(100, S.ennui + dt * (1.5 + S.era * .4));
  if (fade > 0) fade = Math.max(0, fade - dt * .8);

  // draw
  g.globalAlpha = 1;
  sceneFor()(lastP, !!run);
  if (fade > 0) { g.globalAlpha = fade; R('#000', 0, 0, W, H); g.globalAlpha = 1; }

  // hud
  const shown = run ? run.base + timeAt(run.act.years, run.prog) : S.elapsed;
  el.era.textContent = `${S.era + 1}. ${era().name}`;
  el.clock.textContent = fmtClock(shown);
  el.bar.style.width = S.ennui + '%';
  el.ennuiLabel.textContent = 'ennui · ' + ennuiWord(S.ennui);
  cv.style.filter = `grayscale(${clamp((S.ennui - 60) / 40) * .8})`;
  requestAnimationFrame(frame);
}

addEventListener('keydown', e => { if (e.code === 'Space') { fast = true; e.preventDefault(); } });
addEventListener('keyup', e => { if (e.code === 'Space') fast = false; });
$('reset').onclick = () => { if (confirm('Forget everything and start over?')) reset(); };

lastVis = era().acts[0].vis; lastP = S.era === 0 ? 1 : .5;
if (S.era === 0) lastVis = 'room';
say(S.ended ? 'There is nothing left to do. There is nothing left.' : era().intro);
if (S.ended) { lastVis = 'dissolve'; lastP = 1; }
buildUI();
requestAnimationFrame(frame);
