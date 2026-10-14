extends SceneTree
# Checks the debug module: era jumps grant prerequisites, ending screen reachable.
var game: Node
var d: Node
var frames := 0
func _initialize() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	d = load("res://scripts/debug_tools.gd").new()
	d.set("main", game)
	root.add_child(d)
func _process(_dt: float) -> bool:
	frames += 1
	if frames < 3:
		return false
	d.goto_era(5)
	print("era=", game.S["era"], " has found_telescope=", game.has_flag("found_telescope"), " notes=", game.S["notes"].size())
	d.unlock_here()
	var exit_ok := true
	for h in game.hotspots():
		for a in game.avail(h):
			if a["exit"]:
				exit_ok = not game.is_locked(a)
	print("exit unlocked after F3: ", exit_ok)
	d.goto_era(0)
	print("back at era ", game.S["era"], " flags=", game.S["flags"].size())
	d.force_end()
	print("ended=", game.S["ended"], " era=", game.S["era"])
	quit(0)
	return true
