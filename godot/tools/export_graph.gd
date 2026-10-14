extends SceneTree
# Dumps the discovery graph (actions, requirements, discoveries) to docs/progression.json.
#   godot --headless --path godot --script tools/export_graph.gd
func _init() -> void:
	var out := {"eras": [], "notes": Data.NOTES, "auto": Data.AUTO}
	for ei in Data.eras().size():
		var e: Dictionary = Data.eras()[ei]
		var hs: Array = []
		for h in e["hs"]:
			var acts: Array = []
			for a in h["acts"]:
				acts.append({
					"id": a["id"], "name": a["name"], "dur": a["dur"], "years": a["years"],
					"req": a["req"], "needs": a["needs"], "exhausts": a["exhausts"], "give": _gives(a), "once": a["once"],
					"search": a["search"], "exit": a["exit"],
				})
			hs.append({"id": h["id"], "name": h["name"], "show": h["show"], "acts": acts})
		out["eras"].append({"name": e["name"], "hotspots": hs})
	var path := ProjectSettings.globalize_path("res://").path_join("../docs/progression.json")
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(out, "  "))
	print("wrote ", path)
	quit(0)

func _gives(a: Dictionary) -> Array:
	var g: Array = a["give"].duplicate()
	if Data.REVEALS.has(a["id"]):
		for rv in Data.REVEALS[a["id"]]:
			g.append(rv["flag"])
	return g
