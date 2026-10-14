extends SceneTree
# Walking across the world: random 5-20 s / years, places revealed one by one in random order.
var game: Node
var frames := 0
func _initialize() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)

func _process(_dt: float) -> bool:
	frames += 1
	if frames < 3:
		return false
	game.S = game._new_state()
	game.S["era"] = 2
	game.S["flags"]["piano_learned"] = true
	game._enter_era(false)
	game.shot_args = {}
	var h: Dictionary = game.hotspots()[0]
	var a: Dictionary = h["acts"][0]
	var orders := []
	var ok := true
	for i in 4:
		game.start_action(h, a)
		var secs: float = game.run["act"]["sec"]
		var yrs: float = game.run["act"]["years"]
		if secs < 3.0 or secs > 10.0 or absf(secs - yrs) > 0.001:
			ok = false
			print("FAIL duration ", secs, " ", yrs)
		game.run["prog"] = 1.0
		game.finish_action()
		var found := []
		for f in ["place_workshop", "place_conservatory", "place_library", "found_village"]:
			if game.has_flag(f):
				found.append(f)
		if found.size() != i + 1:
			ok = false
			print("FAIL one by one: ", found)
	if game.S["reveal"]["walk"][3] != 3:
		ok = false
		print("FAIL village not last")
	var listed := []
	for hh in game.hotspots():
		for aa in game.visible_acts(hh):
			listed.append(aa["id"])
	if not listed.has("walk"):
		ok = false
		print("FAIL worn-out walk is not listed")
	print("order ", game.S["reveal"]["walk"], " exhausted=", game.S["exhausted"].has("walk"))
	# without the piano skill the conservatory is never found
	game.S = game._new_state()
	game.S["era"] = 2
	game._enter_era(false)
	for i in 4:
		if game.S["exhausted"].has("walk"):
			break
		game.start_action(h, a)
		game.run["prog"] = 1.0
		game.finish_action()
	if game.has_flag("place_conservatory") or not game.S["exhausted"].has("walk") or game.S["counts"]["walk"] != 3:
		ok = false
		print("FAIL no-piano case ", game.S["counts"], game.S["flags"].keys())
	print("RESULT: ", "PASS" if ok and game.S["exhausted"].has("walk") else "FAIL")
	DirAccess.remove_absolute(game.SAVE_PATH)
	quit(0)
	return true
