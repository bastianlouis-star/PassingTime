class_name Synth
extends Node
# Everything you hear is synthesised at runtime: no audio files.
#  - Music: a generative, slowly-thinning ambient piece. The key sinks and the
#    notes get rarer with every era; at the end there is only a drone, then nothing.
#  - SFX: short samples rendered into AudioStreamWAV at start-up.

const RATE := 22050
const MAX_V := 10

const SCALES := [
	[0, 2, 4, 7, 9], [0, 2, 4, 7, 9], [0, 2, 4, 7, 9],
	[0, 2, 3, 7, 9], [0, 2, 3, 7, 10], [0, 3, 5, 7, 10],
	[0, 7, 12, 14, 19], [0, 7, 12], [0],
]
const ROOTS := [57, 55, 53, 52, 50, 47, 43, 38, 31]
const GAP_MIN := [1.4, 1.8, 2.0, 3.0, 4.0, 5.0, 6.0, 10.0, 99.0]
const GAP_MAX := [3.0, 3.5, 4.0, 6.0, 8.0, 10.0, 12.0, 20.0, 99.0]

var mp: AudioStreamPlayer
var pb: AudioStreamGeneratorPlayback
var sfx := {}
var pool: Array = []
var pool_i := 0
var rng := RandomNumberGenerator.new()

var era := 0
var muted := false
var master := 1.0           # fade for the ending
var run_amt := 0.0          # smoothed time-lapse intensity
var run_target := 0.0
var run_prog := 0.0
var t_note := 0.5
var tick_t := 0.0
var noise_lp := 0.0
var drone_ph := 0.0

var v_f := PackedFloat64Array()
var v_ph := PackedFloat64Array()
var v_age := PackedFloat64Array()
var v_att := PackedFloat64Array()
var v_dur := PackedFloat64Array()
var v_amp := PackedFloat64Array()
var v_kind := PackedInt32Array()

func _ready() -> void:
	rng.randomize()
	var bus := AudioServer.bus_count
	AudioServer.add_bus(bus)
	AudioServer.set_bus_name(bus, "Music")
	var rv := AudioEffectReverb.new()
	rv.room_size = 0.85
	rv.damping = 0.45
	rv.wet = 0.38
	rv.dry = 0.8
	AudioServer.add_bus_effect(bus, rv)
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = RATE
	gen.buffer_length = 0.3
	mp = AudioStreamPlayer.new()
	mp.stream = gen
	mp.bus = "Music"
	mp.volume_db = -4.0
	add_child(mp)
	mp.play()
	pb = mp.get_stream_playback() as AudioStreamGeneratorPlayback
	for i in 6:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		pool.append(p)
	_make_sfx()

# ------------------------------------------------------------------ control

func set_era(e: int) -> void:
	era = clampi(e, 0, 8)
	t_note = 0.3
	if era < 8:
		_add_voice(_hz(ROOTS[era]), 3.0, 14.0, 0.05, 0)
		_add_voice(_hz(ROOTS[era] + 7), 4.0, 14.0, 0.04, 0)

func set_run(active: bool, prog: float = 0.0) -> void:
	run_target = 1.0 if active else 0.0
	run_prog = prog

func play(nm: String, vol_db: float = 0.0, pitch: float = 1.0) -> void:
	if muted or not sfx.has(nm):
		return
	var p: AudioStreamPlayer = pool[pool_i]
	pool_i = (pool_i + 1) % pool.size()
	p.stream = sfx[nm]
	p.volume_db = vol_db
	p.pitch_scale = pitch
	p.play()

func toggle_mute() -> void:
	muted = not muted

static func _hz(m: float) -> float:
	return 440.0 * pow(2.0, (m - 69.0) / 12.0)

# -------------------------------------------------------------------- music

func _add_voice(f: float, att: float, dur: float, amp: float, kind: int) -> void:
	if v_f.size() >= MAX_V:
		return
	v_f.append(f)
	v_ph.append(rng.randf())
	v_age.append(0.0)
	v_att.append(att)
	v_dur.append(dur)
	v_amp.append(amp)
	v_kind.append(kind)

func _spawn_note() -> void:
	var sc: Array = SCALES[era]
	var m: int = ROOTS[era] + int(sc[rng.randi() % sc.size()]) + (12 if rng.randf() < 0.45 else 0)
	if era <= 3 and rng.randf() < 0.65:
		_add_voice(_hz(m + 12), 0.01, 5.0, 0.11, 1)
	else:
		var f := _hz(m)
		var a := 0.05 if era < 6 else 0.04
		_add_voice(f, rng.randf_range(2.0, 4.0), rng.randf_range(7.0, 12.0), a, 0)
		_add_voice(f * 1.004, rng.randf_range(2.0, 4.0), rng.randf_range(7.0, 12.0), a * 0.7, 0)

func _process(delta: float) -> void:
	run_amt = move_toward(run_amt, run_target, delta * 1.5)
	if era < 8 and master > 0.01:
		t_note -= delta
		if t_note <= 0.0:
			_spawn_note()
			t_note = rng.randf_range(GAP_MIN[era], GAP_MAX[era])
	if run_target > 0.5 and era <= 3:
		tick_t -= delta
		if tick_t <= 0.0:
			play("tick", -14.0, 0.9 + run_prog * 0.5)
			tick_t = lerpf(0.55, 0.12, run_prog)
	_fill()

func _fill() -> void:
	if pb == null:
		return
	var n := pb.get_frames_available()
	if n <= 0:
		return
	var dt := 1.0 / RATE
	var gain := 0.0 if muted else master
	var drone_amp: float = [0.03, 0.03, 0.035, 0.045, 0.05, 0.06, 0.07, 0.08, 0.05][era]
	var drone_f := _hz(ROOTS[era] - 12)
	var noise_amp := run_amt * (0.025 + 0.006 * era)
	var lp_k := 0.35 - 0.04 * era
	var nv := v_f.size()
	for i in n:
		var s := 0.0
		for k in nv:
			var age := v_age[k]
			var env: float
			if v_kind[k] == 1:
				env = exp(-age * 1.7) * minf(age / v_att[k], 1.0)
			else:
				env = minf(age / v_att[k], 1.0)
				var rem := v_dur[k] - age
				if rem < 3.0:
					env *= maxf(rem, 0.0) / 3.0
			var ph := v_ph[k] + v_f[k] * dt
			ph -= floorf(ph)
			v_ph[k] = ph
			v_age[k] = age + dt
			var w := sin(TAU * ph) + 0.35 * sin(TAU * ph * 2.0) + 0.1 * sin(TAU * ph * 3.0)
			if v_kind[k] == 1:
				w += 0.4 * sin(TAU * ph * 2.76) * exp(-age * 5.0)
			s += w * env * v_amp[k]
		drone_ph += drone_f * dt
		drone_ph -= floorf(drone_ph)
		s += sin(TAU * drone_ph) * drone_amp
		if noise_amp > 0.0005:
			noise_lp += lp_k * ((rng.randf() * 2.0 - 1.0) - noise_lp)
			s += noise_lp * noise_amp
		s *= gain
		pb.push_frame(Vector2(s, s))
	# retire finished voices (iterate backwards)
	var j := v_f.size() - 1
	while j >= 0:
		if v_age[j] >= v_dur[j]:
			v_f.remove_at(j); v_ph.remove_at(j); v_age.remove_at(j); v_att.remove_at(j)
			v_dur.remove_at(j); v_amp.remove_at(j); v_kind.remove_at(j)
		j -= 1

# ---------------------------------------------------------------------- sfx

func _wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 30000.0))
	w.data = bytes
	return w

func _buf(dur: float) -> PackedFloat32Array:
	var b := PackedFloat32Array()
	b.resize(int(dur * RATE))
	return b

func _bell(b: PackedFloat32Array, start: float, f: float, amp: float, decay: float) -> void:
	var o := int(start * RATE)
	for i in range(o, b.size()):
		var t := float(i - o) / RATE
		var e := exp(-t * decay)
		if e < 0.002:
			break
		b[i] += amp * e * (sin(TAU * f * t) + 0.4 * sin(TAU * f * 2.0 * t) * exp(-t * 3.0))

func _noise_burst(b: PackedFloat32Array, start: float, dur: float, amp: float, lp: float) -> void:
	var o := int(start * RATE)
	var y := 0.0
	var n := int(dur * RATE)
	for i in n:
		if o + i >= b.size():
			break
		y += lp * ((rng.randf() * 2.0 - 1.0) - y)
		b[o + i] += y * amp * pow(1.0 - float(i) / n, 2.0)

func _make_sfx() -> void:
	var b: PackedFloat32Array
	# footstep
	b = _buf(0.12); _noise_burst(b, 0.0, 0.08, 1.2, 0.18)
	for i in b.size():
		b[i] += 0.5 * sin(TAU * 85.0 * i / RATE) * exp(-i / float(RATE) * 45.0)
	sfx["step"] = _wav(b)
	# clock tick
	b = _buf(0.05); _noise_burst(b, 0.0, 0.015, 1.5, 0.6)
	_bell(b, 0.0, 1900.0, 0.3, 140.0)
	sfx["tick"] = _wav(b)
	# page turn
	b = _buf(0.5)
	for i in b.size():
		var t := float(i) / b.size()
		b[i] = (rng.randf() * 2.0 - 1.0) * 0.5 * sin(PI * t) * (0.4 + 0.6 * sin(t * 18.0)) * 0.6
	sfx["page"] = _wav(b)
	# search rustle
	b = _buf(0.9)
	for k in 7:
		_noise_burst(b, rng.randf_range(0.0, 0.7), rng.randf_range(0.05, 0.14), 0.7, rng.randf_range(0.15, 0.4))
	sfx["search"] = _wav(b)
	# ui
	b = _buf(0.06); _bell(b, 0.0, 900.0, 0.35, 70.0); sfx["select"] = _wav(b)
	b = _buf(0.2); _bell(b, 0.0, 150.0, 0.5, 18.0); sfx["deny"] = _wav(b)
	b = _buf(0.12); _bell(b, 0.0, 1300.0, 0.3, 60.0); sfx["blip"] = _wav(b)
	# soft completion: two plucked notes
	b = _buf(1.6); _bell(b, 0.0, 392.0, 0.35, 3.0); _bell(b, 0.18, 523.25, 0.3, 2.5); sfx["done"] = _wav(b)
	# discovery arpeggio
	b = _buf(2.2)
	var notes := [523.25, 659.25, 783.99, 1046.5]
	for i in notes.size():
		_bell(b, i * 0.11, notes[i], 0.28, 2.6)
	sfx["discover"] = _wav(b)
	# unlock: click + thunk
	b = _buf(0.5); _bell(b, 0.0, 1500.0, 0.3, 120.0); _bell(b, 0.05, 110.0, 0.7, 12.0); _noise_burst(b, 0.0, 0.02, 0.8, 0.5)
	sfx["unlock"] = _wav(b)
	# whoosh at the start of a time-lapse
	b = _buf(0.9)
	var y := 0.0
	for i in b.size():
		var t := float(i) / b.size()
		y += (0.05 + 0.4 * t) * ((rng.randf() * 2.0 - 1.0) - y)
		b[i] = y * 0.9 * sin(PI * t)
	sfx["whoosh"] = _wav(b)
	# era swell: slow chord
	b = _buf(4.5)
	for i in b.size():
		var t := float(i) / RATE
		var e := sin(PI * t / 4.5)
		e *= e
		b[i] = e * 0.25 * (sin(TAU * 110.0 * t) + 0.7 * sin(TAU * 164.8 * t) + 0.5 * sin(TAU * 220.5 * t))
	sfx["era"] = _wav(b)
	# the end: one very low note, decaying forever
	b = _buf(9.0)
	for i in b.size():
		var t := float(i) / RATE
		b[i] = 0.5 * exp(-t * 0.5) * (sin(TAU * 48.0 * t) + 0.3 * sin(TAU * 96.0 * t))
	sfx["end"] = _wav(b)
