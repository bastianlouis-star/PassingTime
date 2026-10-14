class_name SceneSummit
extends SceneBase
# Era 3: a hilltop above a valley. Forests, villages and families appear in the valley
# below as you watch them grow.

var oak: Node3D
var telescope: Node3D
var scope_tube: Node3D
var ledger: Node3D
var carve: Node3D
var acorn_bits: Node3D
var forest: Node3D
var forest_trees: Array = []
var hamlet: Node3D
var town: Array = []
var family: Node3D
var walkers: Array = []
var _vy := -1.5

func build() -> void:
	outdoor = true
	width_m = 10.0
	hero_z = 1.9
	cam_min = 4.9
	cam_max = 5.2
	marker_y = 2.7
	SkyKit.setup(self)
	var grass := Mk.tex(Tex.grass(), 0.8)
	# the hilltop and the cliff below it
	Kit.ground(self, -8.0, 16.0, -2.5, 10.0, grass)
	Mk.bb(self, -8.0, _vy - 0.5, -2.6, 16.0, 0.0, -2.5, Mk.tex(Tex.strata(), 0.9))
	# valley floor
	Kit.ground(self, -40.0, 60.0, -60.0, -2.5, Mk.tex(Tex.grass(), 0.5, Color(0.9, 1.0, 0.85)), _vy)
	for i in 14:
		var fx := -6.0 + (i % 7) * 4.0
		var fz := -8.0 - (i / 7) * 6.0 - Tex.n2(i, 1, 3) * 3.0
		var col: Color = [Color("6a9a3a"), Color("c8b050"), Color("4a8a40"), Color("a8a050")][i % 4]
		Mk.quad(self, fx + 8.0, _vy + 0.01, fz, 3.4, 4.6, Mk.flat(col, 1.0), Vector3(-90, 0, 0))
	# river
	for i in 9:
		Mk.quad(self, 4.0 + sin(i * 0.8) * 3.0 + i * 1.2, _vy + 0.03, -5.0 - i * 3.2, 1.6, 3.6, Mk.glass(Color("4a9ac0"), 0.95), Vector3(-90, 0, 0))
	forest = Mk.group(self, "forest")
	for i in 42:
		var px := -8.0 + Tex.n2(i, 1, 6) * 28.0
		var pz := -4.5 - Tex.n2(i, 2, 6) * 14.0
		var t := Kit.oak(forest, px, pz, 1.2 + Tex.n2(i, 3, 6) * 1.4, "2f7a3a", i)
		t.position.y = _vy
		forest_trees.append(t)
	hamlet = Mk.group(self, "hamlet")
	var wall := Mk.tex(Tex.plaster("c8b8a0"), 1.5)
	for i in 18:
		var bx := 4.5 + (i % 6) * 1.5 + Tex.n2(i, 1, 7) * 0.4
		var bz := -9.0 - (i / 6) * 1.7
		var h := 0.5 + Tex.n2(i, 2, 7) * 1.1
		var b := Kit.building(hamlet, bx, bz, 0.9, 0.9, h, wall, ["8a3a3a", "6a4a3a", "9a5a3a"][i % 3])
		b.position.y = _vy
		b.set_meta("h", h)
		town.append(b)
	family = Mk.group(self, "family")
	for i in 8:
		var s := Mk.sprite(family, Tex.figure([Color("a04a6a"), Color("4a6aa0"), Color("6aa04a")][i % 3], Color("5b3a29")), 3.0 + i * 0.8, _vy, -6.2, 0.07, true, true)
		walkers.append(s)
	# the old oak, telescope, stone table and the way down
	oak = Kit.oak(self, 2.1, 0.6, 4.6, "2f7a3a", 3)
	carve = Mk.group(self, "carve")
	Mk.bb(carve, 2.0, 1.1, 0.86, 2.3, 1.14, 0.9, Mk.flat(Color("2a1a10")))
	Mk.bb(carve, 2.0, 1.2, 0.86, 2.2, 1.24, 0.9, Mk.flat(Color("2a1a10")))
	Mk.bb(carve, 2.0, 1.1, 0.86, 2.04, 1.3, 0.9, Mk.flat(Color("2a1a10")))
	acorn_bits = Mk.group(self, "acorns")
	for i in 5:
		Mk.sp(acorn_bits, 1.4 + i * 0.35, 0.05, 1.4 + Tex.n2(i, 1, 8) * 0.8, 0.04, Mk.flat(Color("8a5a3a"), 0.6), false)
	telescope = Mk.group(self, "telescope")
	var metal := Mk.tex(Tex.metal("5a5e6a"), 2.0)
	for k in 3:
		var a := k * TAU / 3.0
		var leg := Mk.bb(telescope, -0.02, 0, -0.02, 0.02, 1.35, 0.02, metal)
		leg.position = Vector3(4.5 + cos(a) * 0.3, 0.65, 0.9 + sin(a) * 0.3)
		leg.rotation_degrees = Vector3(sin(a) * 14.0, 0, -cos(a) * 14.0)
	scope_tube = Mk.group(telescope, "tube", 4.5, 1.35, 0.9)
	var tube := Mk.cy(scope_tube, 0.45, 0, 0, 0.07, 0.05, 1.1, Mk.flat(Color("c8923a"), 0.3), 14)
	tube.rotation_degrees = Vector3(0, 0, -78)
	tube.position = Vector3(0.5, 0.1, 0)
	ledger = Mk.group(self, "ledger")
	var st := Mk.tex(Tex.flagstone("8a8f9a"), 1.5)
	Mk.bb(ledger, 6.2, 0.7, 0.4, 7.5, 0.8, 1.3, st)
	Mk.bb(ledger, 6.35, 0, 0.55, 6.55, 0.7, 1.15, st)
	Mk.bb(ledger, 7.15, 0, 0.55, 7.35, 0.7, 1.15, st)
	Mk.bb(ledger, 6.6, 0.8, 0.6, 7.1, 0.84, 1.0, Mk.flat(Color("6a3a2a"), 0.6))
	Mk.bb(ledger, 6.62, 0.84, 0.62, 7.08, 0.86, 0.98, Mk.flat(Color("f0ead8"), 0.8))
	for i in 5:
		Kit.rock(self, 9.2 + i * 0.5, 0.5 + Tex.n2(i, 1, 9) * 0.6, 0.4, "7a7e88", i)
	Kit.tufts(self, -4.0, 14.0, -1.5, 6.0, 70, 7)
	Kit.flowers(self, -3.0, 13.0, 0.5, 5.5, 20, 8)
	Kit.ridge(self, -48.0, -2.0, 12.0, 4.0, Color("4a6a8a"), 0.6, true)
	Kit.ridge(self, -70.0, 0.0, 22.0, 9.0, Color("6a82a0"), 0.8, true)

func update(x: Dictionary, _dt: float) -> void:
	var vis: String = x["vis"]
	var run: bool = x["run"]
	var p: float = x["p"]
	var hot: String = x["hot"]
	var t: float = x["t"]
	SkyKit.update(self, x, 0.0)
	Kit.retint_ridges(self, x["day"])
	show_if(telescope, flag(x, "found_telescope"))
	show_if(ledger, flag(x, "city_grown"))
	show_if(acorn_bits, not flag(x, "has_acorns"))
	show_if(carve, flag(x, "carved_name") or (vis == "none" and run and hot == "oak"))
	var scan := 0.0
	if vis == "search" and run and hot == "telescope":
		scan = sin(t * 1.4) * 0.35
	scope_tube.rotation_degrees.y = rad_to_deg(scan)
	scope_tube.rotation_degrees.z = 4.0 + scan * 6.0
	# forest
	var fg := 0.0
	if flag(x, "forest_grown"):
		fg = 1.0
	elif vis == "forest" and run:
		fg = p
	for i in forest_trees.size():
		var tr: Node3D = forest_trees[i]
		var sc := clampf(fg * 1.6 - Tex.n2(i, 4, 6) * 0.6, 0.0, 1.0)
		tr.visible = sc > 0.02
		tr.scale = Vector3.ONE * maxf(sc, 0.01)
	# village -> city
	var cg := 0.0
	if flag(x, "city_grown"):
		cg = 1.0
	elif vis == "village" and run:
		cg = p
	hamlet.visible = flag(x, "found_village") or cg > 0.0
	for i in town.size():
		var b: Node3D = town[i]
		var base_h: float = b.get_meta("h")
		var seen := clampf(cg * 1.5 + 0.35 - Tex.n2(i, 2, 7) * 0.55, 0.0, 1.0)
		b.visible = seen > 0.0 or not flag(x, "city_grown") and (flag(x, "found_village") and Tex.n2(i, 9, 9) > 0.5)
		var grow := 0.4 + cg * cg * (1.0 + Tex.n2(i, 5, 7) * 2.2)
		b.scale = Vector3(1, maxf(grow, 0.3) * (0.5 + 0.5 * seen), 1)
	# a family through the ages
	var fam := vis == "family" and run
	family.visible = fam
	if fam:
		var n := int(p * 8.0) + 1
		for i in walkers.size():
			var w: Sprite3D = walkers[i]
			w.visible = i < n
			w.position.x = 3.0 + i * 0.8 + sin(t * 2.0 + i) * 0.05
			w.pixel_size = 0.07 * (1.0 - (i % 3) * 0.12)
