class_name SceneRoad
extends SceneBase
# Era 2: a long road through hills. Places appear as you discover them.

var passing: Node3D          # rows of trees/tufts that slide by while you walk
var workshop: Node3D
var paints: Node3D
var easel: Node3D
var canvases: Array = []
var clearing: Node3D
var house: Node3D
var house_walls: MeshInstance3D
var house_roof: Node3D
var house_detail: Node3D
var hamlet: Node3D
var library: Node3D
var conservatory: Node3D
var _scroll_period := 6.0

func build() -> void:
	outdoor = true
	width_m = 14.0
	hero_z = 1.9
	cam_min = 0.9
	cam_max = 12.8
	marker_y = 2.7
	cam_off = 0.8
	SkyKit.setup(self)
	var grass := Mk.tex(Tex.grass(), 0.8)
	Kit.ground(self, -12.0, 38.0, -16.0, 16.0, grass)
	Mk.bb(self, -12.0, 0.0, 1.0, 38.0, 0.03, 2.9, Mk.tex(Tex.dirt(), 1.0))
	for i in 16:
		var pz := 1.1 + Tex.n2(i, 2, 4) * 1.6
		Mk.bb(self, -11.0 + i * 3.1 + Tex.n2(i, 1, 4), 0.03, pz, -10.6 + i * 3.1, 0.06, pz + 0.08, Mk.flat(Color("6a5232"), 1.0))
	Kit.ridge(self, -9.0, 0.0, 2.4, 11.0, Color("3a7a40"), 0.2)
	Kit.ridge(self, -18.0, 0.0, 6.0, 13.0, Color("2a5a46"), 0.4)
	Kit.ridge(self, -32.0, 0.5, 15.0, 3.0, Color("4a6a8a"), 0.65, true)
	Kit.ridge(self, -50.0, 2.0, 22.0, 8.0, Color("6a82a0"), 0.8, true)
	passing = Mk.group(self, "passing")
	for i in 8:
		var px := -12.0 + i * _scroll_period
		Kit.oak(passing, px + 1.0, -3.2, 3.6, "2f7a3a", i)
		Kit.pine(passing, px + 3.6, -5.4, 4.2)
		Kit.tufts(passing, px, px + _scroll_period, 3.3, 5.6, 22, i + 20)
		Kit.flowers(passing, px, px + _scroll_period, 3.2, 5.4, 5, i + 40)
	_milestone()
	_workshop()
	_easel()
	_clearing()
	_library()
	_conservatory()

func _milestone() -> void:
	var st := Mk.tex(Tex.flagstone("8a8f9a"), 1.5)
	Mk.bb(self, 0.65, 0, 0.0, 1.2, 1.05, 0.45, st)
	Mk.bb(self, 0.62, 1.05, -0.03, 1.23, 1.15, 0.48, Mk.tex(Tex.flagstone("a8aeb8"), 1.5))
	Mk.bb(self, 0.7, 0.55, 0.455, 1.1, 0.62, 0.47, Mk.flat(Color("3a3f4c")))
	Mk.bb(self, 0.95, 0.62, 0.455, 1.1, 0.8, 0.47, Mk.flat(Color("3a3f4c")))

func _prism(parent: Node, pos: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var pm := PrismMesh.new()
	pm.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = pm
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	return mi

func _tilt(m: MeshInstance3D, deg: Vector3) -> MeshInstance3D:
	m.rotation_degrees = deg
	return m

func _column(parent: Node, x: float, z: float, h: float, r: float, mat: Material) -> void:
	Mk.bb(parent, x - r * 1.5, 0.1, z - r * 1.5, x + r * 1.5, 0.2, z + r * 1.5, mat)
	Mk.cy(parent, x, 0.2, z, r, r * 0.85, h - 0.35, mat, 12)
	Mk.bb(parent, x - r * 1.6, h - 0.15, z - r * 1.6, x + r * 1.6, h, z + r * 1.6, mat)

# ------------------------------------------------------------ painting workshop
func _workshop() -> void:
	workshop = Mk.group(self, "workshop", 3.0, 0.0, 0.0)
	var pl := Mk.tex(Tex.planks_v("8a5a3c"), 1.2)
	var beam := Mk.tex(Tex.wood("3a2418"), 3.0)
	var stone := Mk.tex(Tex.flagstone("7a7468"), 1.5)
	var roof_m := Mk.tex(Tex.shingles("5a4a6a"), 1.5)
	# stone footing and planked walls
	Mk.bb(workshop, -0.92, 0, -0.18, 0.92, 0.22, 1.5, stone)
	Mk.bb(workshop, -0.85, 0.22, -0.1, 0.85, 2.05, 0.0, pl)
	Mk.bb(workshop, -0.85, 0.22, -0.1, -0.78, 2.05, 1.4, pl)
	Mk.bb(workshop, 0.78, 0.22, -0.1, 0.85, 2.05, 1.4, pl)
	Mk.bb(workshop, -0.85, 0.22, 1.36, -0.28, 2.05, 1.42, pl)
	Mk.bb(workshop, 0.28, 0.22, 1.36, 0.85, 2.05, 1.42, pl)
	Mk.bb(workshop, -0.28, 1.75, 1.36, 0.28, 2.05, 1.42, pl)
	Mk.bb(workshop, -0.28, 0.22, 0.05, 0.28, 1.75, 1.38, Mk.flat(Color("0e0a08"), 1.0))
	# timber frame
	for px in [-0.86, -0.3, 0.3, 0.86]:
		Mk.bb(workshop, px - 0.04, 0.22, 1.4, px + 0.04, 2.05, 1.46, beam)
	Mk.bb(workshop, -0.88, 1.05, 1.4, 0.88, 1.12, 1.46, beam)
	Mk.bb(workshop, -0.88, 2.0, 1.4, 0.88, 2.08, 1.46, beam)
	Mk.bb(workshop, -0.3, 1.7, 1.4, 0.3, 1.76, 1.47, beam)
	# door: frame, open leaf, handle
	Mk.bb(workshop, -0.3, 0.22, 1.4, -0.25, 1.76, 1.47, beam)
	Mk.bb(workshop, 0.25, 0.22, 1.4, 0.3, 1.76, 1.47, beam)
	var leaf := Mk.bb(workshop, -0.27, 0.22, 1.47, 0.0, 1.7, 1.5, Mk.tex(Tex.planks_v("6a3f28"), 2.0))
	leaf.rotation_degrees = Vector3(0, -70, 0)
	leaf.position = Vector3(-0.27, leaf.position.y, 1.5)
	Mk.sp(workshop, -0.3, 0.85, 1.55, 0.02, Mk.flat(Color("d8a040"), 0.3), false)
	# windows with shutters and a flower box
	for wx in [-0.62, 0.62]:
		Mk.bb(workshop, wx - 0.2, 0.85, 1.4, wx + 0.2, 1.45, 1.46, beam)
		Mk.bb(workshop, wx - 0.17, 0.88, 1.46, wx + 0.17, 1.42, 1.47, Mk.glass(Color("7ab8e0"), 0.6))
		Mk.bb(workshop, wx - 0.01, 0.88, 1.465, wx + 0.01, 1.42, 1.49, beam)
		Mk.bb(workshop, wx - 0.17, 1.14, 1.465, wx + 0.17, 1.16, 1.49, beam)
		Mk.bb(workshop, wx - 0.32, 0.88, 1.42, wx - 0.22, 1.42, 1.46, Mk.flat(Color("3a6a8a"), 0.8))
		Mk.bb(workshop, wx + 0.22, 0.88, 1.42, wx + 0.32, 1.42, 1.46, Mk.flat(Color("3a6a8a"), 0.8))
		Mk.bb(workshop, wx - 0.2, 0.7, 1.46, wx + 0.2, 0.84, 1.56, beam)
		for k in 4:
			Mk.sp(workshop, wx - 0.14 + k * 0.095, 0.9, 1.52, 0.04, Mk.flat([Color("d03a30"), Color("ffcd75"), Color("b05ad0"), Color("f0f0e0")][k], 0.6), false)
	# gabled roof with ridge, eaves and a chimney
	_prism(workshop, Vector3(0, 2.05 + 0.42, 0.7), Vector3(2.0, 0.85, 1.95), roof_m)
	Mk.bb(workshop, -0.02, 2.88, -0.28, 0.02, 2.94, 1.68, Mk.tex(Tex.wood("2a1a12"), 3.0))
	Mk.bb(workshop, 0.5, 2.1, 0.1, 0.72, 3.0, 0.32, Mk.tex(Tex.brick("8a4a3a"), 2.0))
	Mk.bb(workshop, 0.47, 2.98, 0.07, 0.75, 3.04, 0.35, stone)
	# skylight for painters' north light
	Mk.bb(workshop, -0.45, 2.45, 0.35, -0.05, 2.5, 0.75, Mk.glass(Color("bfe6f6"), 0.7))
	# hanging sign with a brush
	Mk.bb(workshop, 0.98, 0, 1.55, 1.02, 1.9, 1.59, beam)
	Mk.bb(workshop, 0.7, 1.82, 1.55, 1.02, 1.86, 1.59, beam)
	Mk.bb(workshop, 0.72, 1.4, 1.56, 0.96, 1.8, 1.58, Mk.tex(Tex.wood("c9a66b"), 3.0))
	Mk.sp(workshop, 0.84, 1.62, 1.6, 0.06, Mk.flat(Color("d03a30"), 0.5), false)
	Mk.bb(workshop, 0.83, 1.45, 1.6, 0.85, 1.58, 1.61, beam)
	# leaning canvases, paint pots and a barrel outside
	for k in 3:
		var cv := Mk.bx(workshop, -1.15 + k * 0.08, 0.0, 1.1 - k * 0.07, 0.5, 0.65, 0.03, Mk.uvtex(Tex.canvas_art(10 + k), Color.WHITE, 0.0, 0.8))
		cv.rotation_degrees = Vector3(0, 0, -12 + k * 3)
	Mk.cy(workshop, 1.05, 0, 1.2, 0.17, 0.17, 0.5, Mk.tex(Tex.wood("5a3a24"), 3.0), 12)
	Mk.cy(workshop, 1.05, 0.5, 1.2, 0.15, 0.15, 0.02, Mk.flat(Color("3b5dc9"), 0.4), 12)
	paints = Mk.group(workshop, "paints")
	for i in 3:
		Mk.cy(paints, -0.65 + i * 0.12, 0.0, 1.62, 0.05, 0.05, 0.1, Mk.flat([Color("b13e53"), Color("3b5dc9"), Color("ffcd75")][i], 0.4), 10)

func _easel() -> void:
	easel = Mk.group(self, "easel", -2.85, 0.0, 0.0)
	var w := Mk.tex(Tex.wood("8a5a3a"), 3.0)
	for k in 3:
		var a := k * TAU / 3.0
		var leg := Mk.bb(easel, 7.95 - 0.03, 0, 0.5 - 0.03, 7.95 + 0.03, 1.7, 0.5 + 0.03, w)
		leg.position = Vector3(7.95 + cos(a) * 0.22, 0.85, 0.5 + sin(a) * 0.12)
		leg.rotation_degrees = Vector3(sin(a) * 8.0, 0, -cos(a) * 8.0)
	Mk.bb(easel, 7.61, 0.9, 0.3, 8.29, 1.55, 0.34, Mk.flat(Color("f4f0e0"), 0.9))
	Mk.quad(easel, 7.83, 1.3, 0.345, 0.25, 0.25, Mk.flat(Color("b13e53")))
	Mk.quad(easel, 8.11, 1.15, 0.345, 0.2, 0.3, Mk.flat(Color("3b5dc9")))
	for i in 24:
		var cvs := Mk.group(easel, "cv%d" % i, 8.5 + (i % 6) * 0.2, 0.0, 0.2 + (i / 6) * 0.05)
		Mk.bx(cvs, 0, (i / 6) * 0.2, 0, 0.18, 0.18, 0.03, Mk.uvtex(Tex.canvas_art(i), Color.WHITE, 0.0, 0.8))
		canvases.append(cvs)

func _clearing() -> void:
	# the village: a paved square, a well, cottages behind, and the plot where he builds his house
	clearing = Mk.group(self, "clearing", 7.2, 0.0, 0.0)
	var st := Mk.tex(Tex.flagstone("7a7e88"), 1.5)
	var wood := Mk.tex(Tex.wood("5a3a24"), 3.0)
	Mk.bb(clearing, -0.7, 0, -0.1, 0.7, 0.12, 1.25, st)
	Mk.bb(clearing, -0.64, 0.12, -0.04, 0.64, 0.13, 1.19, Mk.tex(Tex.dirt(), 1.0))
	# garden fence around the plot
	for k in 7:
		Mk.bb(clearing, -0.7 + k * 0.23, 0.12, 1.22, -0.66 + k * 0.23, 0.7, 1.26, wood)
	Mk.bb(clearing, -0.7, 0.5, 1.22, 0.7, 0.54, 1.26, wood)
	# the well
	Mk.cy(clearing, -1.05, 0, 1.0, 0.22, 0.22, 0.45, Mk.tex(Tex.flagstone("8a8f9a"), 1.5), 14)
	Mk.cy(clearing, -1.05, 0.4, 1.0, 0.17, 0.17, 0.03, Mk.flat(Color("1a3a5a"), 0.2), 14)
	Mk.bb(clearing, -1.25, 0.4, 0.97, -1.21, 1.25, 1.03, wood)
	Mk.bb(clearing, -0.89, 0.4, 0.97, -0.85, 1.25, 1.03, wood)
	_prism(clearing, Vector3(-1.05, 1.38, 1.0), Vector3(0.6, 0.3, 0.4), Mk.tex(Tex.shingles("8a3a3a"), 1.5))
	# the cottages that make it a village (only once found)
	hamlet = Mk.group(self, "hamlet", 7.2, 0.0, 0.0)
	var cols := [["c8b08a", "7a3a3a"], ["a8b8c8", "4a5a7a"], ["d8c8a0", "6a4a3a"]]
	var spots := [[-1.0, -1.5], [0.9, -1.8], [0.0, -2.9]]
	for i in 3:
		var cx: float = spots[i][0]
		var cz: float = spots[i][1]
		Mk.bb(hamlet, cx - 0.5, 0, cz - 0.4, cx + 0.5, 0.9, cz + 0.4, Mk.tex(Tex.plaster(cols[i][0]), 1.2))
		_prism(hamlet, Vector3(cx, 1.2, cz), Vector3(1.2, 0.6, 0.95), Mk.tex(Tex.shingles(cols[i][1]), 1.5))
		Mk.bb(hamlet, cx - 0.08, 0, cz + 0.4, cx + 0.08, 0.6, cz + 0.43, Mk.tex(Tex.wood("4a2a1c"), 3.0))
		Mk.bb(hamlet, cx + 0.2, 0.4, cz + 0.4, cx + 0.38, 0.65, cz + 0.43, Mk.glass(Color("f8d070"), 1.0))
		Mk.bb(hamlet, cx + 0.3, 0.9, cz - 0.1, cx + 0.42, 1.55, cz + 0.02, Mk.tex(Tex.brick("8a4a3a"), 2.0))
	# the house he builds himself
	house = Mk.group(self, "house", 7.2, 0.12, 0.6)
	house_walls = Mk.bx(house, 0, 0, 0, 1.0, 1.8, 0.9, Mk.tex(Tex.planks_v("b08860"), 1.2))
	house_walls.position.y = 0.9
	house_roof = _prism(house, Vector3(0, 2.2, 0), Vector3(1.3, 0.8, 1.2), Mk.tex(Tex.shingles("8a3a3a"), 1.5))
	house_detail = Mk.group(house, "house_detail")
	var beam := Mk.tex(Tex.wood("3a2418"), 3.0)
	Mk.bb(house_detail, -0.15, 0, 0.45, 0.15, 1.0, 0.49, Mk.tex(Tex.wood("4a2a1c"), 3.0))
	Mk.sp(house_detail, 0.1, 0.5, 0.5, 0.02, Mk.flat(Color("d8a040"), 0.3), false)
	Mk.bb(house_detail, -0.25, 0.0, 0.46, 0.25, 0.06, 0.62, Mk.tex(Tex.flagstone("8a8f9a"), 1.5))
	for wx in [-0.33, 0.33]:
		Mk.bb(house_detail, wx - 0.14, 0.78, 0.45, wx + 0.14, 1.12, 0.48, beam)
		Mk.bb(house_detail, wx - 0.11, 0.81, 0.48, wx + 0.11, 1.09, 0.49, Mk.glass(Color("f8d070"), 1.0))
		Mk.bb(house_detail, wx - 0.01, 0.81, 0.49, wx + 0.01, 1.09, 0.5, beam)
		Mk.bb(house_detail, wx - 0.24, 0.8, 0.44, wx - 0.15, 1.1, 0.47, Mk.flat(Color("3a6a4a"), 0.8))
		Mk.bb(house_detail, wx + 0.15, 0.8, 0.44, wx + 0.24, 1.1, 0.47, Mk.flat(Color("3a6a4a"), 0.8))
		Mk.bb(house_detail, wx - 0.15, 0.68, 0.46, wx + 0.15, 0.78, 0.56, beam)
		Mk.sp(house_detail, wx - 0.08, 0.8, 0.53, 0.035, Mk.flat(Color("d03a30"), 0.6), false)
		Mk.sp(house_detail, wx + 0.06, 0.8, 0.53, 0.035, Mk.flat(Color("ffcd75"), 0.6), false)
	Mk.bb(house_detail, 0.25, 1.7, -0.25, 0.42, 2.7, -0.08, Mk.tex(Tex.brick("8a4a3a"), 2.0))
	Mk.bb(house_detail, 0.22, 2.68, -0.28, 0.45, 2.74, -0.05, Mk.tex(Tex.flagstone("7a7468"), 1.5))

# -------------------------------------------------------------------- university
func _library() -> void:
	library = Mk.group(self, "library", 11.4, 0.0, 0.0)
	var marble := Mk.tex(Tex.marble(), 2.0)
	var brick := Mk.tex(Tex.brick("a8654a"), 1.4)
	var stone := Mk.tex(Tex.flagstone("b8b0a0"), 1.5)
	var wood := Mk.tex(Tex.wood("3a2418"), 3.0)
	# steps
	Mk.bb(library, -1.0, 0, -0.1, 1.0, 0.1, 1.5, stone)
	Mk.bb(library, -0.9, 0.1, -0.1, 0.9, 0.2, 1.35, stone)
	Mk.bb(library, -0.3, 0.0, 1.5, 0.3, 0.06, 1.62, stone)
	# brick main block
	Mk.bb(library, -0.88, 0.2, -0.1, 0.88, 1.75, 0.95, brick)
	Mk.bb(library, -0.92, 0.2, -0.12, 0.92, 0.5, 0.97, stone)
	Mk.bb(library, -0.92, 1.72, -0.12, 0.92, 1.8, 0.97, stone)
	# arched windows on the front wall and the double door
	for wx in [-0.62, 0.62]:
		Mk.bb(library, wx - 0.14, 0.75, 0.95, wx + 0.14, 1.4, 0.98, stone)
		Mk.bb(library, wx - 0.1, 0.8, 0.98, wx + 0.1, 1.35, 0.99, Mk.glass(Color("f8d070"), 0.9))
		Mk.sp(library, wx, 1.38, 0.98, 0.1, Mk.glass(Color("f8d070"), 0.9), false, 0.7)
		Mk.bb(library, wx - 0.01, 0.8, 0.99, wx + 0.01, 1.45, 1.0, stone)
	Mk.bb(library, -0.2, 0.2, 0.95, 0.2, 1.3, 0.98, wood)
	Mk.bb(library, -0.01, 0.2, 0.98, 0.01, 1.3, 0.99, Mk.tex(Tex.wood("c9a66b"), 3.0))
	Mk.sp(library, 0.06, 0.7, 1.0, 0.02, Mk.flat(Color("d8a040"), 0.3), false)
	# portico: six columns, entablature, pediment with a crest
	for i in 6:
		_column(library, -0.75 + i * 0.3, 1.25, 1.75, 0.065, marble)
	Mk.bb(library, -0.95, 1.75, 1.15, 0.95, 1.95, 1.35, stone)
	_prism(library, Vector3(0, 2.2, 1.25), Vector3(2.0, 0.55, 0.22), marble)
	Mk.sp(library, 0, 2.2, 1.38, 0.07, Mk.flat(Color("d8a040"), 0.3), false)
	# banners between the columns
	for i in 3:
		Mk.bb(library, -0.6 + i * 0.6 - 0.07, 0.95, 1.2, -0.6 + i * 0.6 + 0.07, 1.6, 1.22, Mk.flat([Color("b13e53"), Color("3b5dc9"), Color("38b764")][i], 0.7))
	# clock tower with a copper cap
	Mk.bb(library, -0.28, 1.8, 0.1, 0.28, 2.75, 0.62, brick)
	Mk.bb(library, -0.32, 2.7, 0.06, 0.32, 2.8, 0.66, stone)
	_prism(library, Vector3(0, 3.05, 0.36), Vector3(0.7, 0.5, 0.7), Mk.tex(Tex.shingles("3a7a5a"), 1.5))
	var clock := Mk.cy(library, 0, 2.05, 0.63, 0.15, 0.15, 0.02, Mk.flat(Color("f4f0e0"), 0.5, 0.3), 16)
	clock.rotation_degrees = Vector3(90, 0, 0)
	Mk.bb(library, -0.01, 2.2, 0.645, 0.01, 2.33, 0.655, Mk.flat(Color("1a1a22")))
	Mk.bb(library, -0.01, 2.2, 0.645, 0.08, 2.22, 0.655, Mk.flat(Color("1a1a22")))
	# lawn books
	for i in 4:
		Mk.bx(library, 0.95 + i * 0.05, 0.0, 1.3, 0.04, 0.16 + 0.03 * i, 0.12, Mk.flat([Color("b13e53"), Color("3b5dc9"), Color("38b764"), Color("ffcd75")][i], 0.7))

# ------------------------------------------------------------------ conservatory
func _conservatory() -> void:
	# a stone hall with arched windows, a colonnade, a glass cupola and a grand piano inside
	conservatory = Mk.group(self, "conservatory", 9.3, 0.0, 0.0)
	var plaster := Mk.tex(Tex.plaster("d8cfb8"), 1.2)
	var stone := Mk.tex(Tex.flagstone("b8b0a0"), 1.5)
	var marble := Mk.tex(Tex.marble(), 2.0)
	var black := Mk.tex(Tex.wood("1c1c24"), 3.0, Color(1, 1, 1), 0.4)
	var wood := Mk.tex(Tex.wood("6b3f2a"), 3.0)
	Mk.bb(conservatory, -1.02, 0, -0.2, 1.02, 0.12, 1.4, stone)
	Mk.bb(conservatory, -0.7, 0, 1.4, 0.7, 0.06, 1.52, stone)
	# checkerboard floor
	for ix in 8:
		for iz in 3:
			Mk.bb(conservatory, -0.9 + ix * 0.225, 0.12, 0.05 + iz * 0.3, -0.9 + (ix + 1) * 0.225, 0.125, 0.05 + (iz + 1) * 0.3, Mk.flat(Color("2a2a34") if (ix + iz) % 2 == 0 else Color("e8e0d0"), 0.5))
	# walls
	Mk.bb(conservatory, -0.98, 0.12, -0.2, 0.98, 2.0, -0.08, plaster)
	Mk.bb(conservatory, -0.98, 0.12, -0.2, -0.86, 2.0, 1.15, plaster)
	Mk.bb(conservatory, 0.86, 0.12, -0.2, 0.98, 2.0, 1.15, plaster)
	Mk.bb(conservatory, -1.0, 0.12, -0.22, 1.0, 0.4, 1.17, stone)
	# arched windows on the back wall
	for wx in [-0.55, 0.0, 0.55]:
		Mk.bb(conservatory, wx - 0.13, 0.7, -0.08, wx + 0.13, 1.5, -0.04, Mk.glass(Color("f8d070"), 0.8))
		Mk.sp(conservatory, wx, 1.5, -0.06, 0.13, Mk.glass(Color("f8d070"), 0.8), false, 0.7)
		Mk.bb(conservatory, wx - 0.01, 0.7, -0.05, wx + 0.01, 1.62, -0.03, stone)
	# colonnade, entablature and pediment
	for i in 5:
		_column(conservatory, -0.8 + i * 0.4, 1.3, 1.95, 0.06, marble)
	Mk.bb(conservatory, -0.95, 1.95, 1.18, 0.95, 2.12, 1.4, stone)
	_prism(conservatory, Vector3(0, 2.4, 1.29), Vector3(2.0, 0.6, 0.22), marble)
	Mk.sp(conservatory, 0, 2.4, 1.42, 0.06, Mk.flat(Color("d8a040"), 0.3), false)
	# green roof, ridge, and a glass cupola with a copper dome
	_prism(conservatory, Vector3(0, 2.4, 0.45), Vector3(2.1, 0.75, 1.75), Mk.tex(Tex.shingles("3a7a5a"), 1.5))
	Mk.cy(conservatory, 0, 2.7, 0.45, 0.2, 0.2, 0.3, Mk.glass(Color("bfe6f6"), 0.8), 12)
	Mk.sp(conservatory, 0, 3.05, 0.45, 0.22, Mk.tex(Tex.metal("3a8a6a"), 2.0), true, 0.8)
	Mk.cy(conservatory, 0, 3.2, 0.45, 0.015, 0.015, 0.2, Mk.flat(Color("d8a040"), 0.3), 6, false)
	# the grand piano with its lid propped open, bench and music stand
	Mk.bb(conservatory, -0.65, 0.5, 0.15, 0.3, 0.62, 0.78, black)
	Mk.bb(conservatory, 0.28, 0.45, 0.2, 0.42, 0.55, 0.7, black)
	for lp in [[-0.62, 0.18], [0.25, 0.18], [-0.62, 0.72], [0.38, 0.5]]:
		Mk.cy(conservatory, lp[0], 0.12, lp[1], 0.025, 0.02, 0.4, black, 8)
	var lid := Mk.bb(conservatory, -0.65, 0.0, 0.0, 0.25, 0.03, 0.6, black)
	lid.position = Vector3(-0.2, 0.9, 0.15)
	lid.rotation_degrees = Vector3(-38, 0, 0)
	Mk.bb(conservatory, 0.42, 0.55, 0.3, 0.52, 0.58, 0.62, Mk.flat(Color("f0ece0"), 0.4))
	for k in 6:
		Mk.bx(conservatory, 0.45, 0.58, 0.32 + k * 0.045, 0.04, 0.02, 0.025, Mk.flat(Color("14141c"), 0.3), false)
	Mk.bb(conservatory, 0.58, 0.12, 0.38, 0.84, 0.48, 0.62, wood)
	Mk.bb(conservatory, 0.3, 0.62, 0.35, 0.4, 0.92, 0.37, Mk.flat(Color("f4f0e0"), 0.8))
	# music stands and scores around the hall
	for i in 3:
		Mk.bb(conservatory, -0.85 + i * 0.12, 0.12, 0.9, -0.83 + i * 0.12, 0.95, 0.92, wood)
		Mk.bb(conservatory, -0.9 + i * 0.12, 0.8, 0.88, -0.78 + i * 0.12, 0.95, 0.9, Mk.flat(Color("f4f0e0"), 0.8))
	# hanging lanterns
	for lx in [-0.5, 0.5]:
		Mk.cy(conservatory, lx, 1.5, 0.9, 0.01, 0.01, 0.45, Mk.flat(Color("2a2a34")), 6, false)
		Mk.sp(conservatory, lx, 1.45, 0.9, 0.07, Mk.glass(Color("f8d070"), 1.4), false)

func seat(x: Dictionary) -> Dictionary:
	if x["run"] and String(x["vis"]) == "piano" and String(x["hot"]) == "conservatory":
		return {"pos": Vector3(9.9, 0.0, 0.5), "face": -1}
	return {}

func update(x: Dictionary, _dt: float) -> void:
	var vis: String = x["vis"]
	var run: bool = x["run"]
	var p: float = x["p"]
	var hot: String = x["hot"]
	var scroll: float = x["scroll"]
	SkyKit.update(self, x, 0.0)
	Kit.retint_ridges(self, x["day"])
	passing.position.x = -fposmod(scroll * 0.05, _scroll_period)
	show_if(workshop, flag(x, "place_workshop"))
	show_if(paints, flag(x, "found_paints"))
	show_if(library, flag(x, "place_library"))
	show_if(conservatory, flag(x, "place_conservatory"))
	show_if(easel, flag(x, "found_paints"))
	var n := 0
	if flag(x, "painted"):
		n = 24
	elif vis == "paint" and run and hot == "easel":
		n = int(p * 24.0)
	for i in canvases.size():
		(canvases[i] as Node3D).visible = i < n and flag(x, "found_paints")
	var hp := 0.0
	if flag(x, "built_house"):
		hp = 1.0
	elif vis == "build" and run and hot == "clearing":
		hp = p
	var has_lumber := flag(x, "found_village")
	show_if(clearing, has_lumber)
	house.visible = has_lumber and hp > 0.0
	house_walls.scale = Vector3(1, clampf(hp * 1.3, 0.05, 1.0), 1)
	house_walls.position.y = 0.9 * clampf(hp * 1.3, 0.05, 1.0)
	house_roof.visible = hp > 0.75
	house_detail.visible = hp > 0.75
	show_if(hamlet, has_lumber)
