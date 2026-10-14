extends Node2D
# PASSING TIME - an immortal, alone, with nothing but time.
# Walk (A/D or arrows), act on things (E). What you find opens the next thing.
# There are no shortcuts. Time-lapses play out in real time.
#
# Layers: World (x2 pixel-art scene) + Glow (additive light pass) + Post (bloom/grade
# shader) + Hud (crisp vector text, native resolution).

const SAVE_PATH := "user://passing_time.json"
const FEET := 134.0
const NEAR := 15.0
const YELLOW := Color("ffcd75")
const GRAY_L := Color("94b0c2")
const GRAY := Color("566c86")
const WHITE := Color("f4f4f4")
const LILAC := Color("c8a0ff")

var eras: Array = []
var S := {}                      # saved state
var synth: Synth
var world3d: Stage3D
var post_rect: ColorRect
var hud_canvas: CanvasLayer
var hud: Node2D
var tex := {}
var t := 0.0
var day_t := 0.3
var scroll := 0.0
var hx := 150.0
var face := 1
var moving := false
var run := {}                    # active action
var near_hot := -1
var sel := 0
var input_locked := false        # set by the debug flag panel
var msg := ""
var msg_t := 0.0
var toast := ""
var toast_q := ""
var toast_t := 0.0
var fade := 1.0
var last_vis := "room"
var last_p := 1.0
var step_t := 0.0
var ended_t := 0.0
var closing := false
var closing_t := 0.0
var shot_args := {}
var _shot_frames := 0
var _sb: StyleBoxFlat

func _ready() -> void:
	get_tree().auto_accept_quit = false
	eras = Data.eras()
	synth = Synth.new()
	add_child(synth)
	world3d = Stage3D.new()
	add_child(world3d)
	var post_canvas := CanvasLayer.new()
	post_canvas.layer = 1
	add_child(post_canvas)
	post_rect = ColorRect.new()
	post_rect.size = Vector2(640, 360)
	post_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sm := ShaderMaterial.new()
	sm.shader = load("res://shaders/post.gdshader")
	post_rect.material = sm
	post_canvas.add_child(post_rect)
	hud_canvas = CanvasLayer.new()
	hud_canvas.layer = 2
	add_child(hud_canvas)
	hud = _make_layer(1)
	hud_canvas.add_child(hud)
	_sb = StyleBoxFlat.new()
	_sb.bg_color = Color(0.04, 0.05, 0.12, 0.86)
	_sb.border_color = Color(1.0, 0.8, 0.45, 0.45)
	_sb.set_border_width_all(1)
	_sb.set_corner_radius_all(7)
	_sb.shadow_color = Color(0, 0, 0, 0.45)
	_sb.shadow_size = 8
	_parse_args()
	# [DEBUG] loaded only if the file exists - delete scripts/debug_tools.gd to remove debug mode
	if ResourceLoader.exists("res://scripts/debug_tools.gd") and shot_args.is_empty():
		var d: Node = load("res://scripts/debug_tools.gd").new()
		d.set("main", self)
		hud_canvas.add_child(d)
	_load()
	if not shot_args.is_empty():
		_apply_shot()
	else:
		_enter_era(false)
	if msg == "" and not S["ended"]:
		msg = eras[S["era"]]["intro"]
		msg_t = 10.0

func _make_layer(kind: int) -> Node2D:
	var n := Node2D.new()
	n.set_script(load("res://scripts/layer.gd"))
	n.set("main", self)
	n.set("kind", kind)
	return n

func _parse_args() -> void:
	# Test hook:  -- --shot=era:2;flags:a,b;vis:paint;p:0.5;run:1;hx:100;out:file.png
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--shot="):
			for part in a.substr(7).split(";"):
				var kv := part.split(":", true, 1)
				if kv.size() == 2:
					shot_args[kv[0]] = kv[1]

func _apply_shot() -> void:
	S = _new_state()
	S["era"] = int(shot_args.get("era", "0"))
	for f in str(shot_args.get("flags", "")).split(","):
		if f != "":
			S["flags"][f] = true
			S["notes"].append(f)
	S["real"] = float(shot_args.get("real", "4980"))
	for c in str(shot_args.get("counts", "")).split(","):
		var kv := c.split("=")
		if kv.size() == 2:
			S["counts"][kv[0]] = int(kv[1])
	for e in str(shot_args.get("exh", "")).split(","):
		if e != "":
			S["exhausted"][e] = true
	_enter_era(false)
	last_vis = str(shot_args.get("vis", "room"))
	last_p = float(shot_args.get("p", "1"))
	if shot_args.has("hx"):
		hx = float(shot_args["hx"])
	day_t = float(shot_args.get("day", "0.5"))
	if int(shot_args.get("run", "0")) == 1:
		var hot_id := str(shot_args.get("hot", ""))
		run = {"hot": hot_id, "act": {"vis": last_vis, "sec": 99.0, "years": 100.0, "id": "shot", "name": str(shot_args.get("name", "Doing something")), "give": [], "decay": 1.0, "search": false, "once": false, "exit": false, "line": "", "dur": "a while"}, "prog": last_p, "base": 0.0, "shot": true}
	fade = 0.0
	t = float(shot_args.get("t", "30"))
	if shot_args.has("msg"):
		msg = str(shot_args["msg"])
		msg_t = 99.0
	if shot_args.has("toast"):
		toast = str(shot_args["toast"])
		toast_q = str(shot_args.get("quote", ""))
		toast_t = 99.0
	if int(shot_args.get("closing", "0")) == 1:
		closing = true
		closing_t = 2.0
	if int(shot_args.get("ended", "0")) == 1:
		S["ended"] = true
		ended_t = float(shot_args.get("ended_t", "20"))
		msg = "There is nothing left to do. There is nothing left."
	if shot_args.has("sel"):
		sel = int(shot_args["sel"])
	if shot_args.has("near"):
		near_hot = int(shot_args["near"])

# --------------------------------------------------------------------- state

func _new_state() -> Dictionary:
	return {"era": 0, "flags": {}, "notes": [], "done": {}, "counts": {}, "exhausted": {}, "reveal": {}, "era_start": 0.0, "elapsed": 0.0, "ended": false, "real": 0.0}

func _load() -> void:
	S = _new_state()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		for k in S.keys():
			if parsed.has(k):
				S[k] = parsed[k]
		S["era"] = clampi(int(S["era"]), 0, eras.size() - 1)
	hx = eras[S["era"]]["start_x"]

func _save() -> void:
	if not shot_args.is_empty():
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(S))

func _reset() -> void:
	S = _new_state()
	run = {}
	ended_t = 0.0
	synth.master = 1.0
	_save()
	_enter_era(true)

func _enter_era(announce: bool) -> void:
	var e: Dictionary = eras[S["era"]]
	S["era_start"] = float(S["elapsed"])
	hx = e["start_x"]
	face = 1
	tex = Sprites.hero(S["era"])
	world3d.set_era(S["era"], tex)
	synth.set_era(S["era"])
	last_vis = _idle_vis()
	last_p = 1.0
	near_hot = -1
	sel = 0
	if announce:
		fade = 1.0
		msg = e["intro"]
		msg_t = 12.0
		synth.play("era", -6.0)
	_save()

func xmax() -> float:
	return float(eras[S["era"]].get("xmax", 320.0)) - 12.0

func _idle_vis() -> String:
	return "room" if S["era"] == 0 else "idle"

func has_flag(f: String) -> bool:
	return S["flags"].has(f)

func _all_flags(arr: Array) -> bool:
	for f in arr:
		if not has_flag(f):
			return false
	return true

# ------------------------------------------------------------------ hotspots

func hotspots() -> Array:
	var out: Array = []
	for h in eras[S["era"]]["hs"]:
		if _all_flags(h["show"]):
			out.append(h)
	return out

func avail(h: Dictionary) -> Array:
	var out: Array = []
	for a in h["acts"]:
		if a["once"] and S["done"].has(a["id"]) and not S["exhausted"].has(a["id"]):
			continue
		out.append(a)
	return out

func is_locked(a: Dictionary) -> bool:
	for sft in a["soft"]:
		if not has_flag(sft[0]):
			return true
	if not _all_flags(a["req"]):
		return true
	for n in a["needs"]:
		if int(S["counts"].get(n[0], 0)) < int(n[1]):
			return true
	return false

# the actions you can actually see: locked ones stay hidden until you've earned them
func visible_acts(h: Dictionary) -> Array:
	var out: Array = []
	for a in avail(h):
		if not _all_flags(a["hide"]):
			continue
		if a["exit"] or S["exhausted"].has(a["id"]) or not a["soft"].is_empty() or not is_locked(a):
			out.append(a)      # leaving and worn-out activities stay listed; they answer for themselves
	return out

# what he says when an action is out of reach
func lock_message(a: Dictionary) -> String:
	var miss: Array = []
	for sft in a["soft"]:
		if not has_flag(sft[0]):
			miss.append(String(sft[1]))
	if not miss.is_empty():
		return "I don't have the %s." % " or the ".join(miss)
	for f in a["req"]:
		if not has_flag(f) and a["lock_msgs"].has(f):
			return String(a["lock_msgs"][f])
	return String(a["lock"]) if a["lock"] != "" else "I can't do that yet."

# leaving needs its requirements and enough time spent in this era
func exit_ready(a: Dictionary) -> bool:
	if is_locked(a):
		return false
	return float(S["elapsed"]) - float(S["era_start"]) >= float(a["min_years"])

func can_leave() -> bool:
	for h in hotspots():
		for a in avail(h):
			if a["exit"] and exit_ready(a):
				return true
	return false

func current_hint() -> String:
	for h in eras[S["era"]]["hints"]:
		if has_flag(h["not"]):
			continue
		if h.has("need") and not has_flag(h["need"]):
			continue
		return h["text"]
	return "There is nothing more to find here. You know what comes next."

# ------------------------------------------------------------------- actions

func start_action(h: Dictionary, a: Dictionary) -> void:
	if S["exhausted"].has(a["id"]):
		msg = "It doesn't interest you anymore."
		msg_t = 4.0
		synth.play("deny", -8.0)
		return
	if a["exit"] and not exit_ready(a):
		msg = "The activities here can still pass time for a bit."
		msg_t = 5.0
		synth.play("deny", -8.0)
		return
	if is_locked(a):
		msg = lock_message(a)
		msg_t = 5.0
		synth.play("deny", -8.0)
		return
	hx = clampf(h["x"], 12.0, xmax())
	if int(S["counts"].get(a["id"], 0)) == 0 and shot_args.is_empty():
		toast = String(a["name"])
		toast_q = String(Data.QUOTES.get(a["id"], ""))
		toast_t = 7.0 if toast_q != "" else 4.0
		synth.play("discover", -8.0)
	var ra: Dictionary = a
	if not a["sec_range"].is_empty() and shot_args.is_empty():
		ra = a.duplicate()
		ra["sec"] = randf_range(float(a["sec_range"][0]), float(a["sec_range"][1]))
		ra["years"] = ra["sec"]          # as many years as seconds
		ra["dur"] = "%d years" % int(round(float(ra["sec"])))
	run = {"hot": h["id"], "act": ra, "prog": 0.0, "base": S["elapsed"]}
	last_vis = a["vis"]
	last_p = 0.0
	msg = ""
	synth.set_run(true, 0.0)
	if a["exit"]:
		synth.play("unlock", -4.0)
	elif a["search"]:
		synth.play("search", -4.0)
	else:
		synth.play("whoosh", -10.0)
	if a["vis"] == "book":
		synth.play("page", -8.0)

func finish_action() -> void:
	var a: Dictionary = run["act"]
	run = {}
	synth.set_run(false)
	S["elapsed"] = float(S["elapsed"]) + float(a["years"])
	if a["once"]:
		S["done"][a["id"]] = true
	S["counts"][a["id"]] = int(S["counts"].get(a["id"], 0)) + 1
	last_p = 1.0
	for g in a["give"]:
		_add_flag(g)
	for ex in a["exhausts"]:
		S["exhausted"][ex] = true
	if int(a["max_uses"]) > 0 and int(S["counts"][a["id"]]) >= int(a["max_uses"]):
		S["exhausted"][a["id"]] = true
	if Data.REVEALS.has(a["id"]) and int(S["counts"][a["id"]]) >= _reveal_order(a["id"]).size():
		S["exhausted"][a["id"]] = true
	var line: String = a["line"]
	if Data.REVEALS.has(a["id"]):
		var order := _reveal_order(a["id"])
		var k := int(S["counts"][a["id"]]) - 1
		if k >= 0 and k < order.size():
			var rv: Dictionary = Data.REVEALS[a["id"]][order[k]]
			_add_flag(rv["flag"])
			if line != "":
				line += String(rv["line"])
	for r in Data.AUTO:
		if not has_flag(r["give"]) and Data.auto_gives(S["flags"], S["counts"]).has(r["give"]):
			_add_flag(r["give"])
			if line != "":
				line += String(r.get("line", ""))
	if a["exit"]:
		S["era"] = int(S["era"]) + 1
		_enter_era(true)
		return
	if a["vis"] == "dissolve":
		S["ended"] = true
		ended_t = 0.0
		msg = "There is nothing left to do. There is nothing left."
		if has_flag("crystal_last"):
			msg = "There is nothing left to do. Somewhere, a note is still travelling."
		msg_t = 999.0
		synth.play("end", -2.0)
		synth.master = 0.0
		_save()
		return
	if line != "":
		msg = line
		msg_t = 9.0
	if a["give"].is_empty():
		synth.play("done", -6.0)
	if S["era"] == 0 and a["vis"] in ["book", "tv", "chess", "search", "window", "door", "music", "clock"]:
		last_vis = _idle_vis()
	_save()

# the order in which an action reveals its places is shuffled once per game and saved
func _reveal_order(id: String) -> Array:
	if not S.has("reveal"):
		S["reveal"] = {}
	if not S["reveal"].has(id):
		var o: Array = []
		var last: Array = []
		for i in Data.REVEALS[id].size():
			var need: String = String(Data.REVEALS[id][i].get("need", ""))
			if need == "" or has_flag(need):
				if Data.REVEALS[id][i].get("last", false):
					last.append(i)
				else:
					o.append(i)
		o.shuffle()
		o.append_array(last)       # some places always come last
		S["reveal"][id] = o
	return S["reveal"][id]

func _add_flag(g: String) -> void:
	if has_flag(g):
		return
	S["flags"][g] = true
	S["notes"].append(g)
	synth.play("discover", -5.0)
	for extra in Data.auto_gives(S["flags"], S["counts"]):
		_add_flag(extra)

# ---------------------------------------------------------------------- loop

func _process(dt: float) -> void:
	if shot_args.has("out"):
		_shot_frames += 1
		if _shot_frames == int(shot_args.get("frames", "6")):
			var im := get_viewport().get_texture().get_image()
			if im.get_width() != 1280:
				im.resize(1280, 720, Image.INTERPOLATE_NEAREST)
			im.save_png(str(shot_args["out"]))
			get_tree().quit()
	t += dt
	if shot_args.is_empty():
		S["real"] = float(S["real"]) + minf(dt, 0.25)
	if closing:
		closing_t += dt
		if closing_t >= 4.0 and shot_args.is_empty():
			get_tree().quit()
	var speed_day := 0.012
	if not run.is_empty():
		var a: Dictionary = run["act"]
		if run.get("shot", false):
			speed_day = 0.0
		else:
			run["prog"] = float(run["prog"]) + dt / float(a["sec"])
			last_p = clampf(run["prog"], 0.0, 1.0)
			speed_day = 0.04 + 0.12 * clampf(a["years"] / 20.0, 0.0, 1.0) + (0.25 if a["years"] > 5.0 else 0.0)
			synth.set_run(true, last_p)
			if last_vis == "walk":
				scroll += dt * 90.0
			if run["prog"] >= 1.0:
				finish_action()
		moving = false
	else:
		_move(dt)
	if run.is_empty() and not S["ended"] and not closing:
		var rate := 1.0 if S["era"] == 0 else 3600.0
		S["elapsed"] = float(S["elapsed"]) + dt * rate / (365.25 * 86400.0)
	if S["era"] == 0:
		day_t = 0.333 + shown_time() * 365.25
	else:
		day_t += dt * speed_day
	if S["era"] >= 5:
		day_t = 0.3
	if S["ended"]:
		ended_t += dt
		synth.master = 0.0
	if fade > 0.0:
		fade = maxf(0.0, fade - dt * 0.5)
	if msg_t > 0.0:
		msg_t -= dt
		if msg_t <= 0.0 and not S["ended"]:
			msg = ""
	if toast_t > 0.0:
		toast_t -= dt
	var pm := post_rect.material as ShaderMaterial
	pm.set_shader_parameter("fade", fade * 0.0)
	if world3d.active():
		world3d.update(_ctx(), dt)
	hud.queue_redraw()

func _move(dt: float) -> void:
	if S["ended"] or closing or input_locked:
		moving = false
		return
	var dir := 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir += 1.0
	moving = dir != 0.0
	if moving:
		face = 1 if dir > 0.0 else -1
		hx = clampf(hx + dir * 52.0 * dt, 12.0, xmax())
		step_t -= dt
		if step_t <= 0.0 and S["era"] <= 5:
			synth.play("step", -16.0, randf_range(0.9, 1.1))
			step_t = 0.27
	var best := -1
	var bd := NEAR
	var hs := hotspots()
	for i in hs.size():
		var d := absf(hs[i]["x"] - hx)
		if d < bd:
			bd = d
			best = i
	if best != near_hot:
		near_hot = best
		sel = 0
		if best >= 0:
			synth.play("blip", -14.0)

func request_quit() -> void:
	if closing:
		return
	closing = true
	closing_t = 0.0
	_save()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		request_quit()

func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventKey) or not e.pressed or e.echo:
		return
	var k: int = e.keycode
	if closing or input_locked:
		return
	if k == KEY_F11:
		var m := DisplayServer.window_get_mode()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if m == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	if S["ended"]:
		if k == KEY_R:
			_reset()
		elif k == KEY_ESCAPE:
			request_quit()
		return
	if k == KEY_M:
		synth.toggle_mute()
		return
	if k == KEY_ESCAPE:
		request_quit()
		return
	if not run.is_empty():
		return
	var hs := hotspots()
	if near_hot < 0 or near_hot >= hs.size():
		return
	var h: Dictionary = hs[near_hot]
	var acts := visible_acts(h)
	if acts.is_empty():
		return
	if k == KEY_W or k == KEY_UP:
		sel = (sel - 1 + acts.size()) % acts.size()
		synth.play("select", -10.0)
	elif k == KEY_S or k == KEY_DOWN:
		sel = (sel + 1) % acts.size()
		synth.play("select", -10.0)
	elif k == KEY_E or k == KEY_SPACE or k == KEY_ENTER or k == KEY_KP_ENTER or k == KEY_Z:
		sel = clampi(sel, 0, acts.size() - 1)
		start_action(h, acts[sel])

# ---------------------------------------------------------------------- time

func fmt_clock(y: float) -> String:
	if S["ended"]:
		return "∞"
	if y < 1.0 and S["era"] > 0:
		return "Day %d" % (int(y * 365.25) + 1)
	if y < 1.0:
		var secs := int(y * 365.25 * 86400.0) + 8 * 3600
		var d := secs / 86400 + 1
		var r := secs % 86400
		return "Day %d   %02d:%02d:%02d" % [d, r / 3600, (r % 3600) / 60, r % 60]
	if y < 10000.0:
		return "Year %d, day %d" % [int(y), int(fmod(y, 1.0) * 365.25) + 1]
	if y < 1e6:
		return "%s years" % _commas(int(y))
	if y < 1e9:
		return "%.1f million years" % (y / 1e6)
	if y < 1e12:
		return "%.2f billion years" % (y / 1e9)
	var ex := int(floor(log(y) / log(10.0)))
	return "%.2f × 10^%d years" % [y / pow(10.0, ex), ex]

func _commas(n: int) -> String:
	var s := str(n)
	var out := ""
	var cnt := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			out = "," + out
	return out

# real time spent, in words ("1 hour, 23 minutes and 7 seconds")
func fmt_real(secs: float) -> String:
	var s := int(secs)
	var h := s / 3600
	var m := (s % 3600) / 60
	var sec := s % 60
	var parts: Array = []
	if h > 0:
		parts.append("%d hour%s" % [h, "" if h == 1 else "s"])
	if m > 0:
		parts.append("%d minute%s" % [m, "" if m == 1 else "s"])
	if sec > 0 or parts.is_empty():
		parts.append("%d second%s" % [sec, "" if sec == 1 else "s"])
	if parts.size() == 1:
		return parts[0]
	return ", ".join(parts.slice(0, parts.size() - 1)) + " and " + parts[parts.size() - 1]

func shown_time() -> float:
	if run.is_empty():
		return float(S["elapsed"])
	var a: Dictionary = run["act"]
	var yrs: float = a["years"]
	var p: float = clampf(run["prog"], 0.0, 1.0)
	var add := yrs * p if yrs < 1e4 else pow(yrs, p) - 1.0 + p
	return float(run["base"]) + add


func _pose() -> String:
	if run.is_empty():
		return "walk" if moving else "idle"
	var v: String = run["act"]["vis"]
	if v == "book":
		return "read"
	if v in ["chess", "write", "piano", "game"]:
		return "sit"
	if v == "walk":
		return "walk"
	if v == "search":
		return "bob"
	return "idle"

func _ctx() -> Dictionary:
	var spots: Array = []
	for h in hotspots():
		spots.append(h["x"])
	return {
		"t": t, "day": fposmod(day_t, 1.0), "p": last_p, "vis": last_vis, "run": not run.is_empty(),
		"fl": S["flags"], "hot": run.get("hot", "") if not run.is_empty() else "",
		"hx": hx, "face": face, "pose": _pose(), "tex": tex, "fy": FEET, "scroll": scroll,
		"spots": spots, "ended": S["ended"], "ended_t": ended_t, "float": S["era"] >= 6,
		"era": S["era"], "can_leave": can_leave(), "counts": S["counts"], "aid": (run["act"]["id"] if not run.is_empty() else ""),
	}

# ---------------------------------------------------------------------- HUD
# (physical 640x360 coordinates; no permanent bar: a floating card, subtitles, toasts)

func draw_hud(h: CanvasItem) -> void:
	_hud_top(h)
	_hud_marker(h)
	if run.is_empty() and not S["ended"] and not closing:
		_hud_menu(h)
	if not run.is_empty():
		_hud_running(h)
	elif not S["ended"]:
		_hud_msg(h)
	if toast_t > 0.0:
		_hud_toast(h)
	if S["ended"]:
		_hud_end(h)
	if world3d.active() and world3d.scene.flash_amt > 0.0:
		h.draw_rect(Rect2(0, 0, 640, 360), Color(1, 0.95, 0.85, world3d.scene.flash_amt))
	if fade > 0.0:
		h.draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, fade))
	if closing:
		_hud_closing(h)

func _hud_marker(h: CanvasItem) -> void:
	if not world3d.active() or not run.is_empty() or S["ended"] or closing:
		return
	var hs := hotspots()
	if near_hot < 0 or near_hot >= hs.size():
		return
	if visible_acts(hs[near_hot]).is_empty():
		return
	var p := world3d.project(float(hs[near_hot]["x"]), world3d.scene.marker_y + 0.05)
	var b := sin(t * 5.0) * 2.5
	h.draw_colored_polygon(PackedVector2Array([Vector2(p.x - 5, p.y + b), Vector2(p.x + 5, p.y + b), Vector2(p.x, p.y + b + 7)]), YELLOW)

func _hud_top(h: CanvasItem) -> void:
	var e: Dictionary = eras[S["era"]]
	Txt.draw(h, "%d · %s" % [S["era"] + 1, String(e["name"]).to_upper()], 14, 10, 13, Color(YELLOW.r, YELLOW.g, YELLOW.b, 0.9))
	Txt.draw_right(h, fmt_clock(shown_time()), 626, 9, 15, WHITE)
	if t < 14.0 and S["era"] == 0 and not S["ended"] and run.is_empty():
		var a := clampf((14.0 - t) / 3.0, 0.0, 1.0)
		Txt.draw_center(h, "A D  walk      E / Space  do      M  mute      Esc  quit", 320, 338, 11, Color(GRAY_L.r, GRAY_L.g, GRAY_L.b, a * 0.8))

func _hud_menu(h: CanvasItem) -> void:
	var hs := hotspots()
	if near_hot < 0 or near_hot >= hs.size():
		return
	var hot: Dictionary = hs[near_hot]
	var acts := visible_acts(hot)
	if acts.is_empty():
		return
	var cx: float = float(hot["x"]) * 2.0
	var menu_bottom := 226.0
	if world3d.active():
		var sp := world3d.project(float(hot["x"]), world3d.scene.marker_y)
		cx = sp.x
		menu_bottom = clampf(sp.y - 14.0, 120.0, 250.0)
	cx = clampf(cx, 170.0, 470.0)
	var rows := mini(4, acts.size())
	var top := menu_bottom - 22.0 - rows * 21.0
	Txt.draw_center(h, String(hot["name"]).to_upper(), cx, top, 11, Color(YELLOW.r, YELLOW.g, YELLOW.b, 0.9))
	if acts.is_empty():
		Txt.draw_center(h, "Nothing more here.", cx, top + 20, 13, GRAY)
		return
	sel = clampi(sel, 0, acts.size() - 1)
	var first := clampi(sel - 1, 0, maxi(0, acts.size() - 4))
	for i in mini(4, acts.size() - first):
		var idx := first + i
		var a: Dictionary = acts[idx]
		var yy := top + 20 + i * 21
		var locked := is_locked(a)
		var label: String = String(a["name"])
		var dur := "" if locked or a["dur"] == "" else "   " + String(a["dur"])
		var is_sel := idx == sel
		var exh: bool = S["exhausted"].has(a["id"])
		if exh:
			dur = "   not interesting anymore"
		var col := YELLOW if is_sel else (GRAY if locked else WHITE)
		if exh:
			col = Color("6a7088")
		var size := 15 if is_sel else 13
		var wl := Txt.width(label, size)
		var wd := Txt.width(dur, 11)
		var x0 := cx - (wl + wd) / 2.0
		if is_sel:
			Txt.draw(h, "▸", x0 - 16, yy + 1, 13, YELLOW)
		Txt.draw(h, label, x0, yy, size, col)
		if dur != "":
			Txt.draw(h, dur, x0 + wl, yy + 3, 11, Color(GRAY_L.r, GRAY_L.g, GRAY_L.b, 0.9))

func _hud_running(h: CanvasItem) -> void:
	var a: Dictionary = run["act"]
	Txt.draw_center(h, a["name"], 320, 304, 15, WHITE)
	if a["dur"] != "":
		Txt.draw_center(h, "time passes: " + a["dur"], 320, 324, 11, GRAY_L)
	var p := clampf(run["prog"], 0.0, 1.0)
	h.draw_rect(Rect2(220, 346, 200, 2), Color(1, 1, 1, 0.15))
	h.draw_rect(Rect2(220, 346, 200.0 * p, 2), Color("73eff7"))

func _hud_msg(h: CanvasItem) -> void:
	if msg == "":
		return
	var a := clampf(msg_t / 1.2, 0.0, 1.0)
	var lines := Txt.wrap(msg, 540, 16, true)
	var n := mini(lines.size(), 3)
	for i in n:
		Txt.draw_center(h, lines[i], 320, 346 - (n - i) * 22, 16, Color(1, 1, 1, a), true)

func _hud_toast(h: CanvasItem) -> void:
	var a := clampf(toast_t / 1.0, 0.0, 1.0)
	var qlines := Txt.wrap(toast_q, 470, 12, true) if toast_q != "" else []
	var bh := 30 + qlines.size() * 17
	var y := 40.0
	var rect := Rect2(80, y, 480, bh)
	_sb.bg_color = Color(0.04, 0.05, 0.12, 0.9 * a)
	_sb.border_color = Color(1.0, 0.8, 0.45, 0.6 * a)
	h.draw_style_box(_sb, rect)
	_sb.bg_color = Color(0.04, 0.05, 0.12, 0.86)
	_sb.border_color = Color(1.0, 0.8, 0.45, 0.45)
	Txt.draw(h, "NEW", 94, y + 10, 10, Color(YELLOW.r, YELLOW.g, YELLOW.b, a * 0.85))
	Txt.draw(h, toast, 130, y + 8, 14, Color(1, 0.95, 0.8, a), true)
	for i in qlines.size():
		Txt.draw(h, qlines[i], 130, y + 30 + i * 17, 12, Color(GRAY_L.r, GRAY_L.g, GRAY_L.b, a * 0.95), true)

func _hud_end(h: CanvasItem) -> void:
	# the last atom stops moving at ~10 s; then the silence says how long it took
	if ended_t > 5.0:
		var a := clampf((ended_t - 5.0) / 3.0, 0.0, 1.0)
		var lines := Txt.wrap(msg, 520, 15, true)
		for i in lines.size():
			Txt.draw_center(h, lines[i], 320, 150 + i * 20, 15, Color(1, 1, 1, 0.55 * a), true, false)
	if ended_t > 11.0:
		var a2 := clampf((ended_t - 11.0) / 3.0, 0.0, 1.0)
		Txt.draw_center(h, "You spent", 320, 196, 14, Color(1, 1, 1, 0.45 * a2), true, false)
		Txt.draw_center(h, fmt_real(float(S["real"])), 320, 218, 20, Color(1.0, 0.9, 0.7, 0.9 * a2), true, false)
		Txt.draw_center(h, "passing his time.", 320, 250, 14, Color(1, 1, 1, 0.45 * a2), true, false)
	if ended_t > 18.0:
		var a3 := clampf((ended_t - 18.0) / 3.0, 0.0, 1.0)
		Txt.draw_center(h, "R  begin again          Esc  leave", 320, 328, 11, Color(1, 1, 1, 0.3 * a3), false, false)

func _hud_closing(h: CanvasItem) -> void:
	var a := clampf(closing_t / 0.8, 0.0, 1.0)
	h.draw_rect(Rect2(0, 0, 640, 360), Color(0, 0, 0, a))
	var ta := clampf((closing_t - 0.5) / 0.8, 0.0, 1.0)
	Txt.draw_center(h, "Thank you for passing time with him.", 320, 140, 18, Color(1, 1, 1, 0.8 * ta), true, false)
	Txt.draw_center(h, "You spent", 320, 184, 13, Color(1, 1, 1, 0.5 * ta), true, false)
	Txt.draw_center(h, fmt_real(float(S["real"])), 320, 204, 20, Color(1.0, 0.9, 0.7, 0.95 * ta), true, false)
	Txt.draw_center(h, "here.", 320, 236, 13, Color(1, 1, 1, 0.5 * ta), true, false)
