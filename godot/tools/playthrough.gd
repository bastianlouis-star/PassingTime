extends SceneTree
# Headless end-to-end run of the real game: plays every era through the actual
# game object (shortened time-lapses, boredom forced up). Run:
#   godot --headless --path godot --script tools/playthrough.gd

var game: Node
var frames := 0
var current: Array = []   # queue of [hotspot, action]
var finished := false

func _initialize() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.shot_args = {"nosave": "1"}   # disable saving

func _find(id: String) -> Array:
	for h in game.hotspots():
		for a in game.avail(h):
			if game.S["exhausted"].has(a["id"]):
				continue
			if a["id"] == id:
				return [h, a]
	return []

func _resolve(h: Dictionary, a: Dictionary) -> Array:
	# if an action needs another done N times first, plan that one instead
	for n in a["needs"]:
		if int(game.S["counts"].get(n[0], 0)) < int(n[1]):
			var f := _find(n[0])
			if not f.is_empty():
				return _resolve(f[0], f[1])
	return [h, a]

func _plan() -> void:
	for h in game.hotspots():
		for a in game.avail(h):
			if game.S["exhausted"].has(a["id"]):
				continue
			if not game._all_flags(a["req"]):
				continue
			var fresh_flag: bool = false
			for g in a["give"]:
				if not game.has_flag(g):
					fresh_flag = true
			if fresh_flag or a["exit"] or a["once"] or int(a["max_uses"]) > 0 or Data.REVEALS.has(a["id"]):
				current = _resolve(h, a)
				return
	current = []

func _process(_dt: float) -> bool:
	frames += 1
	if game.S["ended"]:
		print("ENDED after ", frames, " frames; era=", game.S["era"], " notes=", game.S["notes"].size())
		quit(0)
		return true
	if frames > 4000:
		print("TIMEOUT era=", game.S["era"], " flags=", game.S["flags"].keys())
		quit(1)
		return true
	if game.run.is_empty():
		game.fade = 0.0
		_plan()
		if current.is_empty():
			print("STUCK in era ", game.S["era"], " flags=", game.S["flags"].keys())
			quit(1)
			return true
		var a: Dictionary = current[1]
		a["sec"] = 0.05
		if a["exit"]:
			game.S["era_start"] = float(game.S["elapsed"]) - 1000.0
		var before: int = game.S["era"]
		game.start_action(current[0], a)
		if before == 8 and game.run.is_empty():
			print("could not start final action")
	return false
