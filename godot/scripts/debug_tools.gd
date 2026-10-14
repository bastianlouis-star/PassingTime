extends Node2D
# [DEBUG] Self-contained debug mode. To remove it for release, just delete this file
# (main.gd only loads it if it exists). Nothing else depends on it.
#
#   F1 / F2   previous / next era (grants everything the earlier eras gave)
#   F3        unlock everything in the current era (the exit becomes available)
#   F5        flags panel: every gate flag of the current and earlier eras,
#             Up/Down choose, Enter/Space switch on/off, A all on, N all off, F5 closes
#   F6        jump straight to the ending screen
#   F4        hide / show this overlay

var main: Node
var show_overlay := true
var panel := false
var cursor := 0
var scroll := 0
var rows: Array = []        # [flag, era, action name]

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventKey) or not e.pressed or e.echo:
		return
	var k: int = e.keycode
	if panel:
		match k:
			KEY_F5, KEY_ESCAPE:
				_close_panel()
			KEY_UP, KEY_W:
				cursor = maxi(0, cursor - 1)
			KEY_DOWN, KEY_S:
				cursor = mini(rows.size() - 1, cursor + 1)
			KEY_PAGEUP:
				cursor = maxi(0, cursor - 10)
			KEY_PAGEDOWN:
				cursor = mini(rows.size() - 1, cursor + 10)
			KEY_ENTER, KEY_KP_ENTER, KEY_SPACE, KEY_E:
				_toggle(cursor)
			KEY_A:
				for i in rows.size():
					set_flag(rows[i][0], true)
			KEY_N:
				for i in rows.size():
					set_flag(rows[i][0], false)
		scroll = clampi(scroll, maxi(0, cursor - 13), mini(cursor, maxi(0, rows.size() - 14)))
		get_viewport().set_input_as_handled()
		return
	match k:
		KEY_F1: goto_era(int(main.S["era"]) - 1)
		KEY_F2: goto_era(int(main.S["era"]) + 1)
		KEY_F3: unlock_here()
		KEY_F4: show_overlay = not show_overlay
		KEY_F5: _open_panel()
		KEY_F6: force_end()

func _process(_dt: float) -> void:
	queue_redraw()

# ------------------------------------------------------------------ flags panel
func _collect() -> void:
	rows.clear()
	var seen := {}
	var last := int(main.S["era"])
	for ei in range(0, last + 1):
		for h in main.eras[ei]["hs"]:
			for a in h["acts"]:
				for g in a["give"]:
					if not seen.has(g):
						seen[g] = true
						rows.append([g, ei, String(a["name"])])
				if Data.REVEALS.has(a["id"]):
					for rv in Data.REVEALS[a["id"]]:
						if not seen.has(rv["flag"]):
							seen[rv["flag"]] = true
							rows.append([rv["flag"], ei, String(a["name"])])
	for r in Data.AUTO:
		if not seen.has(r["give"]):
			rows.append([r["give"], -1, "(automatic)"])

func _open_panel() -> void:
	_collect()
	cursor = clampi(cursor, 0, maxi(0, rows.size() - 1))
	scroll = 0
	panel = true
	main.input_locked = true

func _close_panel() -> void:
	panel = false
	main.input_locked = false

func set_flag(flag: String, on: bool) -> void:
	var flags: Dictionary = main.S["flags"]
	if on:
		if not flags.has(flag):
			flags[flag] = true
			main.S["notes"].append(flag)
	else:
		flags.erase(flag)
		main.S["notes"].erase(flag)
		# let the actions that gave it be done again
		for ei in main.eras.size():
			for h in main.eras[ei]["hs"]:
				for a in h["acts"]:
					if a["give"].has(flag):
						main.S["done"].erase(a["id"])
						main.S["exhausted"].erase(a["id"])

func _toggle(i: int) -> void:
	if i < 0 or i >= rows.size():
		return
	var f: String = rows[i][0]
	set_flag(f, not main.S["flags"].has(f))

# --------------------------------------------------------------- era jumps etc.
func _give_all(era: int, include_exit: bool) -> void:
	for h in main.eras[era]["hs"]:
		for a in h["acts"]:
			if a["exit"] and not include_exit:
				continue
			for g in a["give"]:
				if not main.S["flags"].has(g):
					main.S["flags"][g] = true
					main.S["notes"].append(g)
			if Data.REVEALS.has(a["id"]):
				for rv in Data.REVEALS[a["id"]]:
					if not main.S["flags"].has(rv["flag"]):
						main.S["flags"][rv["flag"]] = true
						main.S["notes"].append(rv["flag"])
			if a["once"]:
				main.S["done"][a["id"]] = true
			if a["once"] and a["years"] < 1e10:
				main.S["elapsed"] = float(main.S["elapsed"]) + float(a["years"])

func _auto() -> void:
	for g in Data.auto_gives(main.S["flags"], main.S["counts"]):
		main.S["flags"][g] = true
		main.S["notes"].append(g)

func goto_era(n: int) -> void:
	n = clampi(n, 0, main.eras.size() - 1)
	main.S["flags"] = {}
	main.S["notes"] = []
	main.S["done"] = {}
	main.S["exhausted"] = {}
	main.S["elapsed"] = 0.0
	main.S["ended"] = false
	main.synth.master = 1.0
	for e in n:
		_give_all(e, true)
	_auto()
	main.S["era"] = n
	main.run = {}
	main._enter_era(true)
	if panel:
		_collect()
		cursor = clampi(cursor, 0, maxi(0, rows.size() - 1))

func unlock_here() -> void:
	_give_all(int(main.S["era"]), false)
	_auto()
	main.S["era_start"] = float(main.S["elapsed"]) - 10.0
	main.msg = "[debug] everything in this era unlocked."
	main.msg_t = 4.0

func force_end() -> void:
	main.S["era"] = main.eras.size() - 1
	main.run = {}
	main.S["ended"] = true
	main.ended_t = 0.0
	main.synth.master = 0.0
	main.msg = "There is nothing left to do. There is nothing left."
	main.msg_t = 999.0
	main._enter_era(false)
	main.S["ended"] = true

# ------------------------------------------------------------------------ draw
func _draw() -> void:
	if show_overlay:
		var s := "DEBUG   F1/F2 era %d/9   F3 unlock era   F5 flags   F6 ending   F4 hide" % (int(main.S["era"]) + 1)
		var w := Txt.width(s, 10)
		draw_rect(Rect2(320 - w / 2.0 - 8, 4, w + 16, 16), Color(0.5, 0.0, 0.0, 0.6))
		Txt.draw_center(self, s, 320, 6, 10, Color(1, 0.8, 0.8))
	if not panel:
		return
	var x0 := 400.0
	var y0 := 26.0
	var pw := 232.0
	draw_rect(Rect2(x0, y0, pw, 318), Color(0.05, 0.0, 0.0, 0.88))
	draw_rect(Rect2(x0, y0, pw, 318), Color(0.8, 0.3, 0.3, 0.8), false, 1.0)
	var on_count := 0
	for r in rows:
		if main.S["flags"].has(r[0]):
			on_count += 1
	Txt.draw(self, "FLAGS  %d / %d on" % [on_count, rows.size()], x0 + 8, y0 + 6, 11, Color(1, 0.85, 0.85))
	Txt.draw(self, "Up/Down  Enter toggle  A all  N none", x0 + 8, y0 + 20, 9, Color(0.8, 0.6, 0.6))
	var last_era := -2
	var y := y0 + 38.0
	for i in range(scroll, mini(rows.size(), scroll + 14)):
		var r: Array = rows[i]
		var on: bool = main.S["flags"].has(r[0])
		if i == cursor:
			draw_rect(Rect2(x0 + 3, y - 1, pw - 6, 18), Color(1, 0.4, 0.4, 0.25))
		draw_rect(Rect2(x0 + 8, y + 2, 9, 9), Color(0.15, 0.15, 0.15), true)
		draw_rect(Rect2(x0 + 8, y + 2, 9, 9), Color(0.8, 0.8, 0.8), false, 1.0)
		if on:
			draw_rect(Rect2(x0 + 10, y + 4, 5, 5), Color(0.5, 1.0, 0.5))
		Txt.draw(self, String(r[0]), x0 + 22, y - 1, 10, Color(0.6, 1.0, 0.6) if on else Color(0.75, 0.75, 0.8))
		Txt.draw(self, "era %s · %s" % [str(int(r[1]) + 1) if int(r[1]) >= 0 else "-", String(r[2])], x0 + 22, y + 8, 8, Color(0.6, 0.6, 0.7))
		y += 20.0
		last_era = int(r[1])
	if rows.size() > 14:
		Txt.draw_right(self, "%d-%d / %d" % [scroll + 1, mini(rows.size(), scroll + 14), rows.size()], x0 + pw - 8, y0 + 6, 9, Color(0.8, 0.6, 0.6))
