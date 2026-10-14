extends SceneTree
# Headless check: every era's chain of discoveries can be completed from scratch,
# and every flag is both obtainable and documented.  Run:
#   godot --headless --path godot --script tools/test_chain.gd

func _init() -> void:
	var eras := Data.eras()
	var ok := true
	var flags := {}
	var given := {}
	var fake_counts := {}
	for era in eras:
		for h in era["hs"]:
			for a in h["acts"]:
				fake_counts[a["id"]] = 99
	for ei in eras.size():
		var e: Dictionary = eras[ei]
		var exited := false
		var done := {}
		var steps := 0
		var progress := true
		while progress:
			progress = false
			for h in e["hs"]:
				var shown := true
				for f in h["show"]:
					if not flags.has(f):
						shown = false
				if not shown:
					continue
				for a in h["acts"]:
					if done.has(a["id"]) and a["once"]:
						continue
					var can := true
					for f in a["req"]:
						if not flags.has(f):
							can = false
					if not can:
						continue
					if a["once"]:
						done[a["id"]] = true
					var newf: bool = a["once"]
					for g in a["give"]:
						if not flags.has(g):
							newf = true
						flags[g] = true
						given[g] = true
					if Data.REVEALS.has(a["id"]):
						for rv in Data.REVEALS[a["id"]]:
							if not flags.has(rv["flag"]):
								newf = true
							flags[rv["flag"]] = true
							given[rv["flag"]] = true
					for extra in Data.auto_gives(flags, fake_counts):
						flags[extra] = true
						given[extra] = true
						newf = true
					if not newf and not a["exit"]:
						continue
					steps += 1
					if not exited:
						progress = true
					if a["exit"]:
						exited = true
		if ei < eras.size() - 1 and not exited:
			print("FAIL era %d (%s): cannot reach the exit" % [ei, e["name"]])
			ok = false
		else:
			print("ok   era %d %-14s %d steps" % [ei, e["name"], steps])
	for g in given:
		if not Data.NOTES.has(g):
			print("WARN flag '%s' has no journal note" % g)
	for ei in eras.size():
		for h in eras[ei]["hs"]:
			for a in h["acts"]:
				for f in a["req"]:
					if not given.has(f):
						print("FAIL req flag '%s' is never given (%s)" % [f, a["id"]])
						ok = false
	for ei in eras.size():
		for h in eras[ei]["hs"]:
			for a in h["acts"]:
				if not Data.QUOTES.has(a["id"]):
					print("WARN no quote for action ", a["id"])
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
