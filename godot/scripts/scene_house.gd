class_name SceneHouse
extends SceneBase
# Era 1: a cut-away house with an attic, a desk, a piano and a stove, and a sunlit yard
# with an apple tree, a garden plot, a shed and the gate to the road.

var weeds: Node3D
var crops: Node3D
var pages: Node3D
var piano: Node3D
var piano_sheet: Node3D
var scope: Node3D
var scope_tube: Node3D
var yard: Node3D
var shed_door: Node3D
var shed_dark: Node3D
var sign: Node3D
var notebook: Node3D
var letters: Node3D
var stove_fire: MeshInstance3D
var stove_light: OmniLight3D
var steam: CPUParticles3D
var lamp: OmniLight3D
var apples: Node3D
var apples2: Node3D
var attic_light: OmniLight3D

func build() -> void:
	outdoor = true
	width_m = 14.0
	hero_z = 1.9
	cam_min = 5.0
	cam_max = 8.0
	marker_y = 2.7
	SkyKit.setup(self)
	var wp := Mk.tex(Tex.wallpaper(), 1.0, Color(1.25, 1.0, 0.9))
	var wa := Mk.tex(Tex.wainscot(), 1.0, Color(1.2, 1.0, 0.9))
	var wf := Mk.tex(Tex.wood_floor(), 1.0)
	var trim := Mk.tex(Tex.wood("4a2a1c"), 2.0)
	var wood_l := Mk.tex(Tex.wood("8a5a3a"), 3.0)
	var wood_d := Mk.tex(Tex.wood("4a2a1c"), 3.0)
	# ------------------------------------------------------------- the house
	Mk.bb(self, 0, -0.2, -0.2, 6.6, 0, 5.0, wf)
	var ceil := Mk.bb(self, -0.2, 3.0, -0.3, 6.8, 3.2, 5.0, Mk.flat(Color.BLACK))
	ceil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	var lz0 := 1.6
	var lz1 := 3.2
	var ly0 := 1.1
	var ly1 := 2.3
	Mk.bb(self, -0.2, 0, -0.2, 0, 3.0, lz0, wp)
	Mk.bb(self, -0.2, 0, lz1, 0, 3.0, 5.0, wp)
	Mk.bb(self, -0.2, 0, lz0, 0, ly0, lz1, wp)
	Mk.bb(self, -0.2, ly1, lz0, 0, 3.0, lz1, wp)
	var lf := Mk.tex(Tex.wood("c9a66b"), 3.0)
	Mk.bb(self, -0.24, ly0 - 0.04, lz0 - 0.04, 0.04, ly0 + 0.04, lz1 + 0.04, lf)
	Mk.bb(self, -0.24, ly1 - 0.04, lz0 - 0.04, 0.04, ly1 + 0.04, lz1 + 0.04, lf)
	Mk.bb(self, -0.24, ly0, lz0 - 0.04, 0.04, ly1, lz0 + 0.04, lf)
	Mk.bb(self, -0.24, ly0, lz1 - 0.04, 0.04, ly1, lz1 + 0.04, lf)
	Mk.bb(self, -0.22, ly0, (lz0 + lz1) / 2.0 - 0.02, 0.02, ly1, (lz0 + lz1) / 2.0 + 0.02, lf)
	# back wall with a window above the desk
	var wx0 := 2.45
	var wx1 := 3.45
	var wy0 := 1.25
	var wy1 := 2.45
	_wall(0.0, wx0, 0.0, 3.0, wp, wa)
	_wall(wx0, wx1, 0.0, wy0, wp, wa)
	_wall(wx0, wx1, wy1, 3.0, wp, wa)
	_wall(wx1, 6.6, 0.0, 3.0, wp, wa)
	Mk.bb(self, 0, 0, 0, 6.6, 0.14, 0.05, trim)
	Mk.bb(self, 0, 2.92, 0, 6.6, 3.0, 0.07, trim)
	var gable := PrismMesh.new()
	gable.size = Vector3(7.0, 1.9, 0.22)
	var gi := MeshInstance3D.new()
	gi.mesh = gable
	gi.material_override = Mk.tex(Tex.planks_v("8a6a5a"), 1.0)
	gi.position = Vector3(3.3, 3.0 + 0.95, -0.1)
	add_child(gi)
	var rf := Mk.tex(Tex.wood("c9a66b"), 3.0)
	Mk.bb(self, wx0 - 0.05, wy0 - 0.05, -0.12, wx1 + 0.05, wy0 + 0.03, 0.04, rf)
	Mk.bb(self, wx0 - 0.05, wy1 - 0.03, -0.12, wx1 + 0.05, wy1 + 0.05, 0.04, rf)
	Mk.bb(self, wx0 - 0.05, wy0, -0.12, wx0 + 0.03, wy1, 0.04, rf)
	Mk.bb(self, wx1 - 0.03, wy0, -0.12, wx1 + 0.05, wy1, 0.04, rf)
	Mk.bb(self, (wx0 + wx1) / 2.0 - 0.015, wy0, -0.08, (wx0 + wx1) / 2.0 + 0.015, wy1, 0.0, rf)
	Mk.bb(self, wx0, (wy0 + wy1) / 2.0 - 0.015, -0.08, wx1, (wy0 + wy1) / 2.0 + 0.015, 0.0, rf)
	# round attic window in the gable
	Mk.cy(self, 3.3, 3.55, 0.02, 0.28, 0.28, 0.05, Mk.flat(Color("c9a66b"))).rotation_degrees = Vector3(90, 0, 0)
	Mk.cy(self, 3.3, 3.55, 0.05, 0.22, 0.22, 0.02, Mk.glass(Color("bfe6f6"), 1.0)).rotation_degrees = Vector3(90, 0, 0)
	attic_light = Mk.omni(self, 1.6, 3.6, 0.8, Color(1.0, 0.8, 0.5), 0.5, 3.0, false)
	# door post where the house ends
	Mk.bb(self, 6.55, 0, -0.1, 6.7, 3.0, 0.15, wood_d)
	# rug
	Mk.quad(self, 3.3, 0.006, 2.4, 3.6, 1.9, Mk.uvtex(Tex.rug(), Color(0.9, 0.9, 1.0), 0.0, 0.95), Vector3(-90, 0, 0))
	# ladder to the attic hatch
	for rx in [0.78, 1.02]:
		Mk.bb(self, rx - 0.02, 0, 0.1, rx + 0.02, 3.0, 0.16, wood_l)
	for k in 9:
		Mk.bb(self, 0.78, 0.3 + k * 0.3, 0.1, 1.02, 0.34 + k * 0.3, 0.16, wood_d)
	_stove(wood_d)
	_desk(wood_l, wood_d)
	_piano()
	_scope()
	# ---------------------------------------------------------------- yard
	yard = Mk.group(self, "yard", 1.5, 0.0, 0.0)
	var grass := Mk.tex(Tex.grass(), 0.8)
	Kit.ground(self, 6.6, 16.0, -14.0, 14.0, grass)
	Kit.ground(self, -12.0, 0.0, -14.0, 14.0, grass)
	Kit.ground(self, 0.0, 6.6, -14.0, -0.2, grass)
	Mk.bb(yard, 8.6, 0.0, 1.0, 14.0, 0.02, 4.0, Mk.tex(Tex.dirt(), 1.0))
	Kit.fence(yard, 5.3, 12.0, -0.9)
	Kit.fence(yard, 5.3, 12.0, 6.5)
	Kit.tufts(yard, 5.3, 11.5, -0.6, 2.5, 50, 3)
	Kit.tufts(yard, 8.0, 11.5, 2.5, 5.5, 40, 4)
	Kit.flowers(yard, 5.5, 10.5, 0.2, 2.3, 16, 5)
	Kit.flowers(yard, 8.0, 10.5, 2.5, 5.0, 10, 6)
	_apple_tree()
	_garden()
	_shed()
	_gate()
	Kit.ridge(self, -11.0, 0.0, 2.2, 1.0, Color("3a7a40"), 0.2)
	Kit.ridge(self, -22.0, 0.0, 7.0, 3.0, Color("2f6a46"), 0.45)
	Kit.ridge(self, -40.0, 1.0, 17.0, 6.0, Color("4a6a8a"), 0.7, true)
	Kit.oak(yard, 11.5, -3.0, 4.2, "2f7a3a", 4)
	Kit.oak(yard, 13.0, 1.5, 3.4, "3a8a40", 5)
	Kit.oak(self, -3.0, 0.5, 4.5, "2f7a3a", 6)
	lamp = Mk.omni(self, 2.7, 2.65, 1.7, Color(1.0, 0.82, 0.55), 0.9, 6.0, true)

func _wall(x0: float, x1: float, y0: float, y1: float, wp: Material, wa: Material) -> void:
	var wain := 0.95
	if y0 < wain:
		Mk.bb(self, x0, y0, -0.2, x1, minf(y1, wain), 0.0, wa)
	if y1 > wain:
		Mk.bb(self, x0, maxf(y0, wain), -0.2, x1, y1, 0.0, wp)

func _stove(wood_d: Material) -> void:
	var m := Mk.tex(Tex.metal("2a2d38"), 2.0)
	Mk.bb(self, 1.35, 0.0, 0.1, 2.1, 1.1, 0.8, m)
	Mk.bb(self, 1.3, 1.1, 0.05, 2.15, 1.18, 0.85, Mk.tex(Tex.metal("1a1c24"), 2.0))
	stove_fire = Mk.quad(self, 1.72, 0.6, 0.805, 0.5, 0.3, Mk.glass(Color("3a1c14"), 1.0))
	Mk.cy(self, 1.72, 1.18, 0.35, 0.07, 0.07, 1.9, m, 10)
	Mk.cy(self, 1.5, 1.18, 0.4, 0.13, 0.12, 0.12, Mk.tex(Tex.metal("4a4d58"), 2.0), 12)
	Mk.bb(self, 1.4, 0, 0.8, 1.5, 0.08, 0.9, wood_d)
	stove_light = Mk.omni(self, 1.72, 0.6, 1.2, Color(1.0, 0.5, 0.2), 0.0, 3.0, false)
	steam = CPUParticles3D.new()
	steam.amount = 18
	steam.lifetime = 3.0
	steam.position = Vector3(1.5, 1.35, 0.4)
	steam.gravity = Vector3(0, 0.15, 0)
	steam.direction = Vector3(0, 1, 0)
	steam.spread = 14.0
	steam.initial_velocity_min = 0.05
	steam.initial_velocity_max = 0.12
	steam.scale_amount_min = 0.8
	steam.scale_amount_max = 2.0
	var q := QuadMesh.new()
	q.size = Vector2(0.08, 0.08)
	steam.mesh = q
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.albedo_texture = Tex.radial(Color(1, 1, 1, 0.5), 1.0)
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	steam.material_override = sm
	steam.emitting = false
	add_child(steam)

func _desk(wood_l: Material, wood_d: Material) -> void:
	# the desk stands turned 50 degrees so the profile hero can sit facing it
	var dx := 2.94
	var g := Mk.group(self, "deskg", dx, 0.0, 0.45)
	g.rotation_degrees = Vector3(0, 50, 0)
	Mk.bb(g, -0.7, 0.72, -0.35, 0.7, 0.77, 0.3, wood_l)
	Mk.bb(g, -0.65, 0.4, -0.3, 0.65, 0.72, 0.25, wood_d)
	for lx in [-0.66, 0.64]:
		Mk.bb(g, lx - 0.03, 0, -0.32, lx + 0.03, 0.72, -0.26, wood_d)
		Mk.bb(g, lx - 0.03, 0, 0.21, lx + 0.03, 0.72, 0.27, wood_d)
	Mk.bb(g, 0.1, 0.5, 0.25, 0.6, 0.68, 0.29, wood_l)
	Mk.sp(g, 0.35, 0.6, 0.31, 0.02, Mk.flat(Color("d8a040"), 0.3))
	# chair, facing the desk
	Mk.bb(g, -0.2, 0.42, 0.42, 0.2, 0.46, 0.82, wood_l)
	Mk.bb(g, -0.2, 0.46, 0.79, 0.2, 1.0, 0.82, wood_d)
	for lx in [-0.18, 0.16]:
		for lz in [0.44, 0.78]:
			Mk.bb(g, lx, 0, lz, lx + 0.03, 0.42, lz + 0.03, wood_d)
	# lamp on the desk
	Mk.cy(g, 0.45, 0.77, -0.2, 0.012, 0.012, 0.3, Mk.flat(Color("8a8a96")), 6, false)
	Mk.cy(g, 0.45, 1.05, -0.2, 0.13, 0.05, 0.1, Mk.flat(Color("d8a040"), 0.4), 12)
	notebook = Mk.group(g, "notebook")
	Mk.bx(notebook, -0.35, 0.77, -0.05, 0.3, 0.02, 0.22, Mk.flat(Color("6a3a2a"), 0.6))
	Mk.bx(notebook, -0.35, 0.79, -0.05, 0.26, 0.006, 0.19, Mk.flat(Color("f0ead8"), 0.8))
	letters = Mk.group(g, "letters")
	Mk.bx(letters, 0.1, 0.77, -0.1, 0.22, 0.04, 0.16, Mk.flat(Color("e0d4b0"), 0.8))
	Mk.bx(letters, 0.1, 0.81, -0.1, 0.22, 0.01, 0.02, Mk.flat(Color("a04050"), 0.8))
	pages = Mk.group(g, "pages")
	Mk.bx(pages, 0.0, 0.0, 0.0, 0.26, 1.0, 0.19, Mk.flat(Color("f4f0e0"), 0.9))
	pages.position = Vector3(-0.05, 0.77, 0.0)

func _piano() -> void:
	piano = Mk.group(self, "piano")
	var blk := Mk.tex(Tex.wood("1c1c24"), 3.0, Color(1, 1, 1), 0.4)
	var px := 5.6
	Mk.bb(piano, px - 0.8, 0.0, 0.05, px + 0.8, 1.35, 0.6, blk)
	Mk.bb(piano, px - 0.82, 1.35, 0.03, px + 0.82, 1.4, 0.64, Mk.tex(Tex.wood("2a2a34"), 3.0))
	Mk.bb(piano, px - 0.78, 0.7, 0.6, px + 0.78, 0.78, 0.82, blk)
	Mk.bb(piano, px - 0.74, 0.78, 0.62, px + 0.74, 0.8, 0.8, Mk.flat(Color("f0ece0"), 0.4))
	for k in 24:
		Mk.bx(piano, px - 0.72 + k * 0.0625, 0.8, 0.8, 0.003, 0.002, 0.18, Mk.flat(Color("90909a")), false)
	for k in 17:
		if k % 7 != 2 and k % 7 != 6:
			Mk.bx(piano, px - 0.7 + k * 0.0875, 0.8, 0.68, 0.035, 0.03, 0.12, Mk.flat(Color("14141c"), 0.3), false)
	Mk.bb(piano, px - 0.5, 1.0, 0.45, px + 0.5, 1.25, 0.5, Mk.flat(Color("e8e0c8"), 0.8))
	Mk.bb(piano, px - 0.4, 0.0, 1.05, px + 0.0, 0.45, 1.45, Mk.tex(Tex.wood("6b3f2a"), 3.0))
	# a dust sheet over it until he starts to learn
	piano_sheet = Mk.group(self, "piano_sheet")
	var cloth := Mk.flat(Color("d8d2c0"), 1.0)
	Mk.bb(piano_sheet, px - 0.86, 0.0, 0.0, px + 0.86, 1.45, 0.7, cloth)
	Mk.bb(piano_sheet, px - 0.86, 0.66, 0.7, px + 0.86, 0.84, 0.9, cloth)
	Mk.bb(piano_sheet, px - 0.5, 0.0, 0.7, px + 0.5, 0.66, 0.88, cloth)

func _scope() -> void:
	# a brass telescope on a tripod, pointing out through the window in the left wall
	scope = Mk.group(self, "scope", 1.05, 0.0, 2.4)
	var brass := Mk.tex(Tex.metal("b08a3a"), 2.0)
	var wd := Mk.tex(Tex.wood("5a3a24"), 3.0)
	for k in 3:
		var a := k * TAU / 3.0 + 0.4
		var leg := Mk.cy(scope, cos(a) * 0.28, 0.0, sin(a) * 0.28, 0.018, 0.018, 1.2, wd, 6, false)
		leg.rotation = Vector3(-sin(a) * 0.22, 0.0, cos(a) * 0.22)
	scope_tube = Mk.group(scope, "tube", 0.0, 1.2, 0.0)
	Mk.cy(scope_tube, 0.0, 0.0, 0.0, 0.05, 0.065, 1.1, brass, 12)
	var dir := Vector3(-1.0, 0.3, 0.0).normalized()
	scope_tube.basis = Basis(Quaternion(Vector3.UP, dir))
	Mk.sp(scope_tube, 0.0, 0.0, 0.0, 0.07, brass, false)

func _apple_tree() -> void:
	var g := Mk.group(yard, "apple", 5.75, 0.0, 0.5)
	Mk.cy(g, 0, 0, 0, 0.22, 0.14, 2.3, Mk.tex(Tex.bark(), 2.5), 10)
	var leaf := Mk.tex(Tex.leaves("3a8a40"), 2.2)
	for i in 9:
		var a := i * TAU / 9.0
		Mk.sp(g, cos(a) * 0.9, 2.5 + 0.4 * sin(i * 1.7), sin(a) * 0.7, 0.75 + 0.2 * Tex.n2(i, 1, 9), leaf, true, 0.85)
	Mk.sp(g, 0, 3.1, 0, 1.1, leaf, true, 0.9)
	apples = Mk.group(g, "apples")
	apples2 = Mk.group(g, "apples2")
	for i in 14:
		var ap := apples if i < 8 else apples2
		var a := Tex.n2(i, 2, 9) * TAU
		var r := 0.7 + Tex.n2(i, 3, 9) * 0.5
		Mk.sp(ap, cos(a) * r, 2.1 + Tex.n2(i, 4, 9) * 1.1, 0.6 + sin(a) * 0.4, 0.07, Mk.flat(Color("c8342a") if i < 8 else Color("e8c040"), 0.4), false)

func _garden() -> void:
	# a big bed at the front of the yard, so the work can be seen
	var x0 := 5.4
	var x1 := 7.8
	var z0 := 2.8
	var z1 := 4.6
	var soil := Mk.tex(Tex.dirt(), 1.5, Color(0.75, 0.6, 0.5))
	Mk.bb(yard, x0, 0.0, z0, x1, 0.2, z1, soil)
	for k in 6:
		Mk.bb(yard, x0 + 0.05, 0.2, z0 + 0.1 + k * 0.28, x1 - 0.05, 0.23, z0 + 0.17 + k * 0.28, Mk.flat(Color("4a3220"), 1.0))
	var board := Mk.tex(Tex.wood("6b3f2a"), 3.0)
	Mk.bb(yard, x0 - 0.06, 0.0, z0 - 0.06, x1 + 0.06, 0.26, z0, board)
	Mk.bb(yard, x0 - 0.06, 0.0, z1, x1 + 0.06, 0.26, z1 + 0.06, board)
	Mk.bb(yard, x0 - 0.06, 0.0, z0, x0, 0.26, z1, board)
	Mk.bb(yard, x1, 0.0, z0, x1 + 0.06, 0.26, z1, board)
	weeds = Mk.group(yard, "weeds")
	var wt := Tex.tuft("6a7a3a")
	for i in 56:
		Mk.sprite(weeds, wt, x0 + 0.1 + Tex.n2(i, 1, 21) * (x1 - x0 - 0.2), 0.2, z0 + 0.1 + Tex.n2(i, 2, 21) * (z1 - z0 - 0.2), 0.05, true, true)
	crops = Mk.group(yard, "crops")
	for i in 20:
		var cg := Mk.group(crops, "c%d" % i, x0 + 0.3 + (i % 5) * 0.45, 0.2, z0 + 0.3 + (i / 5) * 0.4)
		Mk.cy(cg, 0, 0, 0, 0.014, 0.014, 0.6, Mk.flat(Color("3a8a40")), 5, false)
		for k in 3:
			Mk.sp(cg, 0.04 * (k - 1), 0.3 + k * 0.12, 0.0, 0.06, Mk.flat(Color("3a8a40"), 0.6), false)
		Mk.sp(cg, 0.05, 0.24, 0.04, 0.04, Mk.flat(Color("d03a30"), 0.4), false)
	for k in 5:
		Mk.bb(yard, x0 + 0.25 + k * 0.5, 0.2, z0 + 0.12, x0 + 0.29 + k * 0.5, 1.6, z0 + 0.16, Mk.tex(Tex.wood("8a5a3a"), 3.0))

# he works at the back edge of the bed
func seat(x: Dictionary) -> Dictionary:
	if not x["run"]:
		return {}
	match String(x["vis"]):
		"garden":
			return {"pos": Vector3(float(x["hx"]) * U, 0.0, 2.55), "face": x["face"]}
		"write":
			return {"pos": Vector3(3.5, 0.0, 1.0), "face": -1}
		"piano":
			return {"pos": Vector3(5.4, 0.0, 1.3), "face": 1}
		"sky":
			return {"pos": Vector3(1.45, 0.0, 2.4), "face": -1}
	return {}

func _shed() -> void:
	var pl := Mk.tex(Tex.planks_v("7a4c32"), 1.2)
	var x0 := 7.5
	var x1 := 9.0
	var d := 1.4
	Mk.bb(yard, x0, 0, -0.1, x1, 2.2, 0.0, pl)
	Mk.bb(yard, x0 - 0.1, 0, -0.1, x0, 2.2, d, pl)
	Mk.bb(yard, x1, 0, -0.1, x1 + 0.1, 2.2, d, pl)
	Mk.bb(yard, x0, 0, d, 7.85, 2.2, d + 0.1, pl)
	Mk.bb(yard, 8.5, 0, d, x1, 2.2, d + 0.1, pl)
	Mk.bb(yard, 7.85, 1.8, d, 8.5, 2.2, d + 0.1, pl)
	var roof := Mk.bb(yard, x0 - 0.3, 2.2, -0.2, x1 + 0.3, 2.28, d + 0.4, Mk.tex(Tex.shingles("5a5e6a"), 1.5))
	roof.rotation_degrees = Vector3(12, 0, 0)
	roof.position.y += 0.25
	shed_dark = Mk.group(yard, "shed_dark")
	Mk.bb(shed_dark, 7.85, 0, 0.05, 8.5, 1.8, d + 0.02, Mk.flat(Color("0e0a08"), 1.0))
	Mk.bb(shed_dark, 7.9, 0.0, 0.1, 8.0, 1.2, 0.2, Mk.tex(Tex.metal("6a6a76"), 2.0))
	Mk.bb(shed_dark, 8.2, 0.0, 0.1, 8.26, 1.5, 0.16, Mk.tex(Tex.wood("8a5a3a"), 3.0))
	shed_door = Mk.group(yard, "shed_door")
	Mk.bb(shed_door, 7.85, 0, d, 8.5, 1.8, d + 0.06, Mk.tex(Tex.planks_v("8a5a3a"), 1.4))
	Mk.sp(shed_door, 8.4, 0.9, d + 0.1, 0.03, Mk.flat(Color("d8a040"), 0.3))

func _gate() -> void:
	var w := Mk.tex(Tex.wood("8a5a3a"), 3.0)
	Mk.bb(yard, 9.9, 0, 0.8, 10.0, 2.0, 0.9, w)
	Mk.bb(yard, 10.9, 0, 0.8, 11.0, 2.0, 0.9, w)
	Mk.bb(yard, 9.9, 1.9, 0.8, 11.0, 2.0, 0.9, w)
	Mk.bb(yard, 10.05, 0.2, 0.84, 10.9, 0.25, 0.88, w)
	Mk.bb(yard, 10.05, 0.9, 0.84, 10.9, 0.95, 0.88, w)
	sign = Mk.group(yard, "sign")
	Mk.bb(sign, 10.4, 0, 0.35, 10.46, 1.6, 0.4, w)
	Mk.bb(sign, 10.1, 1.2, 0.4, 10.76, 1.5, 0.43, Mk.tex(Tex.wood("c9a66b"), 3.0))
	Mk.bb(sign, 10.25, 1.3, 0.43, 10.65, 1.34, 0.44, Mk.flat(Color("4a2a1c")))

func update(x: Dictionary, _dt: float) -> void:
	var t: float = x["t"]
	var vis: String = x["vis"]
	var run: bool = x["run"]
	var p: float = x["p"]
	var hot: String = x["hot"]
	SkyKit.update(self, x, 0.0)
	Kit.retint_ridges(self, x["day"])
	show_if(piano_sheet, not flag(x, "piano_uncovered"))
	show_if(scope, flag(x, "found_telescope"))
	show_if(notebook, flag(x, "found_notebook"))
	show_if(letters, flag(x, "found_letters"))
	show_if(sign, flag(x, "found_letters"))
	var shed_open := flag(x, "found_seeds") or (vis == "search" and run and hot == "shed")
	show_if(shed_door, not shed_open)
	show_if(shed_dark, true)
	# pages stack
	# the stack of pages grows with each of the three writing sessions
	var counts: Dictionary = x["counts"]
	var pg := 0.0
	if flag(x, "book_written"):
		pg = 1.0
	elif int(counts.get("write2", 0)) > 0:
		pg = 0.66
	elif int(counts.get("write", 0)) > 0:
		pg = 0.33
	var aid: String = x["aid"]
	if run and hot == "desk" and aid in ["write", "write2", "write3"]:
		pg = maxf(pg, pg + p * 0.34)
	pg = clampf(pg, 0.0, 1.0)
	pages.scale = Vector3(1, maxf(pg * 0.18, 0.001), 1)
	pages.visible = pg > 0.02
	# garden state
	var cleared := flag(x, "garden_cleared")
	var gr := 0.0
	if flag(x, "garden_grown"):
		gr = 1.0
	elif vis == "garden" and run and hot == "garden" and cleared:
		gr = p
	var clearing := vis == "garden" and run and hot == "garden" and not cleared
	weeds.visible = (not cleared) or clearing
	weeds.scale = Vector3(1, 1.0 - (p if clearing else 0.0), 1)
	crops.visible = cleared and gr > 0.02
	crops.scale = Vector3(1, maxf(gr, 0.05), 1)
	show_if(apples, flag(x, "apples_grown"))
	show_if(apples2, flag(x, "grafted"))
	# stove
	var cooking := vis == "cook" and run
	stove_light.light_energy = (1.2 + 0.2 * sin(t * 14.0)) if cooking else 0.0
	steam.emitting = cooking
	(stove_fire.material_override as StandardMaterial3D).albedo_color = Color("ff9a40") if cooking else Color("3a1c14")
	lamp.light_energy = lerpf(0.9, 1.4, SkyKit.night_amt(x["day"]))
	attic_light.light_energy = 0.6 if flag(x, "found_letters") else 0.15
