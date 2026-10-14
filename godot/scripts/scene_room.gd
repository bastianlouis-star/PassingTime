class_name SceneRoom
extends SceneBase
# Era 0: the room. A cut-away diorama; the only daylight comes through the window.

var gram: Node3D
var chess: Node3D
var almanac: Node3D
var door_closed: Node3D
var door_open: Node3D
var outside: Node3D
var record: MeshInstance3D
var tv_screen: MeshInstance3D
var tv_mats: Array = []
var tv_off_mat: StandardMaterial3D
var tv_light: OmniLight3D
var comp_screen: MeshInstance3D
var comp_mats: Array = []
var comp_off: StandardMaterial3D
var comp_light: OmniLight3D
var read_lamp: OmniLight3D
var clock_h: Node3D
var clock_m: Node3D
var lamp: OmniLight3D
var room_fill: OmniLight3D
var sky_a: StandardMaterial3D
var sky_b: StandardMaterial3D
var dust: CPUParticles3D
var steam: CPUParticles3D
var win_glow: OmniLight3D

const WIN := Vector4(9.75, 1.0, 10.65, 2.5)         # x0, y0, x1, y1
const DOOR := Vector4(11.6, 0.0, 12.4, 2.25)

func build() -> void:
	width_m = 12.5
	hero_z = 1.75
	cam_min = 4.7
	cam_max = 7.9
	marker_y = 2.55
	make_env(Color("0b0d18"), Color(0.3, 0.34, 0.5), 0.9)
	make_sun(18.0)
	var wp := Mk.tex(Tex.wallpaper(), 1.0)
	var wa := Mk.tex(Tex.wainscot(), 1.0)
	var trim := Mk.tex(Tex.wood("4a2a1c"), 2.0)
	var trim_l := Mk.tex(Tex.wood("8a5a3a"), 2.0)
	# --- shell
	Mk.bb(self, 0, -0.2, -0.2, 12.5, 0, 7.0, Mk.tex(Tex.wood_floor(), 1.0))
	var ceil := Mk.bb(self, 0, 4.0, -0.2, 12.5, 4.2, 7.0, Mk.flat(Color.BLACK))
	ceil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	Mk.bb(self, -0.2, 0, -0.2, 0, 4.0, 7.0, wp)
	Mk.bb(self, 12.5, 0, -0.2, 12.7, 4.0, 7.0, wp)
	_wall(0.0, WIN.x, 0.0, 4.0, wp, wa)
	_wall(WIN.x, WIN.z, 0.0, WIN.y, wp, wa)
	_wall(WIN.x, WIN.z, WIN.w, 4.0, wp, wa)
	_wall(WIN.z, DOOR.x, 0.0, 4.0, wp, wa)
	_wall(DOOR.x, DOOR.z, DOOR.w, 4.0, wp, wa)
	_wall(DOOR.z, 12.5, 0.0, 4.0, wp, wa)
	Mk.bb(self, 0, 0, 0, DOOR.x, 0.14, 0.05, trim)
	Mk.bb(self, DOOR.z, 0, 0, 12.5, 0.14, 0.05, trim)
	Mk.bb(self, 0, 0.93, 0, 12.5, 1.0, 0.05, trim_l)
	Mk.bb(self, 0, 3.86, 0, 12.5, 4.0, 0.09, trim)
	Mk.bb(self, 0, 3.8, 0, 12.5, 3.86, 0.05, trim_l)
	_window()
	_door()
	# --- furniture
	_bookshelf()
	_gramophone()
	_computer()
	_comp_chair()
	_armchair()
	_tv()
	_clock()
	_cabinet()
	_table()
	_picture()
	_lamp()
	_rug()
	_foreground()
	# --- ambient motes drifting in the window light
	dust = CPUParticles3D.new()
	dust.amount = 40
	dust.lifetime = 9.0
	dust.preprocess = 9.0
	dust.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	dust.emission_box_extents = Vector3(1.4, 1.0, 1.1)
	dust.position = Vector3(9.4, 1.6, 1.4)
	dust.gravity = Vector3.ZERO
	dust.direction = Vector3(-1, 0.2, 0.3)
	dust.initial_velocity_min = 0.02
	dust.initial_velocity_max = 0.08
	dust.scale_amount_min = 0.5
	dust.scale_amount_max = 1.0
	var dm := QuadMesh.new()
	dm.size = Vector2(0.012, 0.012)
	dust.mesh = dm
	var dmat := StandardMaterial3D.new()
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmat.albedo_color = Color(1.0, 0.95, 0.8, 0.8)
	dmat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	dmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dust.material_override = dmat
	add_child(dust)
	room_fill = Mk.omni(self, 5.9, 2.6, 2.6, Color(1.0, 0.92, 0.8), 0.25, 14.0, false)
	win_glow = Mk.omni(self, 10.2, 1.8, 0.6, Color(1.0, 0.95, 0.8), 0.0, 5.0, false)

func _wall(x0: float, x1: float, y0: float, y1: float, wp: Material, wa: Material) -> void:
	var wain := 0.95
	if y0 < wain:
		Mk.bb(self, x0, y0, -0.2, x1, minf(y1, wain), 0.0, wa)
	if y1 > wain:
		Mk.bb(self, x0, maxf(y0, wain), -0.2, x1, y1, 0.0, wp)

# ------------------------------------------------------------------- window
func _window() -> void:
	var fr := Mk.tex(Tex.wood("c9a66b"), 3.0)
	var x0 := WIN.x
	var y0 := WIN.y
	var x1 := WIN.z
	var y1 := WIN.w
	var xm := (x0 + x1) / 2.0
	var ym := (y0 + y1) / 2.0
	Mk.bb(self, x0 - 0.04, y0 - 0.04, -0.15, x1 + 0.04, y0 + 0.03, 0.03, fr)
	Mk.bb(self, x0 - 0.04, y1 - 0.03, -0.15, x1 + 0.04, y1 + 0.04, 0.03, fr)
	Mk.bb(self, x0 - 0.04, y0, -0.15, x0 + 0.03, y1, 0.03, fr)
	Mk.bb(self, x1 - 0.03, y0, -0.15, x1 + 0.04, y1, 0.03, fr)
	Mk.bb(self, xm - 0.015, y0, -0.1, xm + 0.015, y1, 0.0, fr)
	Mk.bb(self, x0, ym - 0.015, -0.1, x1, ym + 0.015, 0.0, fr)
	Mk.bb(self, x0 - 0.1, y0 - 0.07, 0.0, x1 + 0.1, y0 - 0.02, 0.2, fr)
	# the world outside: sky + far hills (unshaded so it glows)
	sky_a = Mk.glass(Color("41a6f6"), 1.0)
	sky_b = Mk.glass(Color("a6dcf2"), 1.0)
	Mk.quad(self, xm, 1.75, -3.0, 6.0, 2.7, sky_a)
	var low := Mk.quad(self, xm, 1.2, -2.98, 6.0, 1.6, sky_b)
	var gm := StandardMaterial3D.new()
	gm.albedo_texture = _fade_tex()
	gm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gm.albedo_color = Color("a6dcf2")
	sky_b = gm
	low.material_override = gm
	var hill := Mk.glass(Color("2a5a3a"), 1.0)
	for i in 6:
		Mk.sp(self, xm - 3.0 + i * 1.3, 0.35, -2.9, 1.3 + Tex.n2(i, 1, 3), hill, false, 0.55)
	var tree := Mk.glass(Color("1d3a2a"), 1.0)
	for i in 4:
		Mk.sp(self, xm - 0.9 + i * 0.6, 0.95, -2.6, 0.32, tree, false)
		Mk.bb(self, xm - 0.93 + i * 0.6, 0.4, -2.6, xm - 0.87 + i * 0.6, 0.9, -2.58, Mk.glass(Color("2a1a10")), false)
	# curtains
	var red := Mk.tex(Tex.wood("8a2a3a"), 3.0, Color(1, 1, 1))
	for side in 2:
		var cx: float = x0 - 0.16 if side == 0 else x1 + 0.04
		Mk.bb(self, cx, y0 - 0.15, 0.04, cx + 0.12, y1 + 0.2, 0.2, red)
		for k in 3:
			Mk.bb(self, cx + 0.02 + k * 0.035, y0 - 0.15, 0.2, cx + 0.035 + k * 0.035, y1 + 0.2, 0.23, Mk.flat(Color("5a1c28")))
	Mk.cy(self, x0 - 0.2, y1 + 0.2, 0.12, 0.018, 0.018, x1 - x0 + 0.4, Mk.flat(Color("c9a66b")), 8, false).rotation_degrees = Vector3(0, 0, 90)

func _fade_tex() -> ImageTexture:
	var img := Image.create(4, 64, false, Image.FORMAT_RGBA8)
	for y in 64:
		var a := 1.0 - float(y) / 63.0
		a = pow(a, 0.6)
		for x in 4:
			img.set_pixel(x, y, Color(1, 1, 1, a))
	return ImageTexture.create_from_image(img)

# --------------------------------------------------------------------- door
func _door() -> void:
	var fr := Mk.tex(Tex.wood("4a2a1c"), 3.0)
	var dw := Mk.tex(Tex.wood("7a4a30"), 3.0)
	Mk.bb(self, DOOR.x - 0.06, 0, -0.14, DOOR.x, DOOR.w + 0.07, 0.05, fr)
	Mk.bb(self, DOOR.z, 0, -0.14, DOOR.z + 0.06, DOOR.w + 0.07, 0.05, fr)
	Mk.bb(self, DOOR.x - 0.06, DOOR.w, -0.14, DOOR.z + 0.06, DOOR.w + 0.07, 0.05, fr)
	door_closed = Mk.group(self, "door_closed")
	Mk.bb(door_closed, DOOR.x, 0, -0.1, DOOR.z, DOOR.w, -0.03, dw)
	for r in 2:
		var py := 0.25 + r * 1.15
		var ph := 0.8 if r == 0 else 0.7
		Mk.bb(door_closed, DOOR.x + 0.1, py, -0.03, DOOR.z - 0.1, py + ph, 0.0, Mk.tex(Tex.wood("5a3420"), 3.0))
	Mk.sp(door_closed, DOOR.z - 0.1, 1.05, 0.04, 0.035, Mk.flat(Color("d8a040"), 0.3))
	door_open = Mk.group(self, "door_open")
	var pivot := Mk.group(door_open, "pivot", DOOR.x, 0, -0.06)
	pivot.rotation_degrees = Vector3(0, -72, 0)
	Mk.bb(pivot, 0, 0, -0.03, DOOR.z - DOOR.x, DOOR.w, 0.03, dw)
	Mk.sp(pivot, DOOR.z - DOOR.x - 0.1, 1.05, 0.07, 0.035, Mk.flat(Color("d8a040"), 0.3))
	outside = Mk.group(self, "outside")
	Mk.quad(outside, (DOOR.x + DOOR.z) / 2.0, 1.1, -0.2, 0.8, 2.25, Mk.glass(Color("bfe6f6"), 1.15))
	Mk.quad(outside, (DOOR.x + DOOR.z) / 2.0, 0.2, -0.19, 0.8, 0.4, Mk.glass(Color("5aa04a"), 1.0))
	Mk.omni(outside, (DOOR.x + DOOR.z) / 2.0, 1.2, 0.5, Color(1.0, 0.95, 0.8), 0.9, 3.5, false)

# ---------------------------------------------------------------- bookshelf
func _bookshelf() -> void:
	var wd := Mk.tex(Tex.wood("5a3a24"), 2.5)
	var wl := Mk.tex(Tex.wood("7a5030"), 2.5)
	var x0 := 0.32
	var x1 := 1.88
	var h := 2.6
	Mk.bb(self, x0, 0, 0.0, x1, h, 0.04, Mk.flat(Color("23150e")))
	Mk.bb(self, x0 - 0.03, 0, 0.0, x0 + 0.03, h, 0.36, wd)
	Mk.bb(self, x1 - 0.03, 0, 0.0, x1 + 0.03, h, 0.36, wd)
	Mk.bb(self, x0 - 0.04, h, 0.0, x1 + 0.04, h + 0.05, 0.38, wl)
	var cols := [Color("a04050"), Color("3a6aa0"), Color("4a9a5a"), Color("c8a850"), Color("7a4a9a"), Color("3a8a8a"), Color("d07a4a"), Color("8a9ab0"), Color("2a3a7a"), Color("a0603a")]
	var shelf_y := [0.08, 0.66, 1.24, 1.82]
	for r in 4:
		var sy: float = shelf_y[r]
		Mk.bb(self, x0 + 0.03, sy - 0.035, 0.0, x1 - 0.03, sy, 0.36, wl)
		var bxp := x0 + 0.08
		var i := 0
		while bxp < x1 - 0.14:
			var s := r * 40 + i
			var bw := 0.035 + Tex.n2(s, 1, 7) * 0.04
			var bh := 0.26 + Tex.n2(s, 2, 7) * 0.24
			if Tex.n2(s, 5, 7) > 0.93:
				bxp += 0.12
				i += 1
				continue
			var col: Color = cols[int(Tex.n2(s, 3, 7) * cols.size())]
			var b := Mk.bx(self, bxp + bw / 2.0, sy, 0.19, bw, bh, 0.24, Mk.flat(col, 0.7))
			if Tex.n2(s, 6, 7) > 0.9:
				b.rotation_degrees.z = -8.0
			Mk.bx(self, bxp + bw / 2.0, sy + bh * 0.62, 0.315, bw * 0.9, 0.012, 0.004, Mk.flat(Color("e0c070"), 0.4))
			bxp += bw + 0.004
			i += 1
	# the almanac, hidden among the books until you find it
	almanac = Mk.group(self, "almanac")
	Mk.bx(almanac, 1.28, shelf_y[1], 0.28, 0.06, 0.42, 0.26, Mk.flat(Color("2c7a45"), 0.6))
	Mk.bx(almanac, 1.28, shelf_y[1] + 0.2, 0.415, 0.05, 0.012, 0.01, Mk.flat(Color("ffcd75"), 0.3))
	# trinkets on top: a small globe and a stack of books
	Mk.cy(self, 0.62, h + 0.05, 0.2, 0.05, 0.03, 0.04, Mk.flat(Color("3a2a1c")), 10)
	Mk.sp(self, 0.62, h + 0.2, 0.2, 0.1, Mk.flat(Color("3a8a9a"), 0.4))
	Mk.bx(self, 1.35, h + 0.05, 0.2, 0.34, 0.05, 0.24, Mk.flat(Color("a04050")))
	Mk.bx(self, 1.36, h + 0.1, 0.2, 0.3, 0.05, 0.22, Mk.flat(Color("3a6aa0")))
	Mk.bx(self, 1.34, h + 0.15, 0.2, 0.28, 0.04, 0.2, Mk.flat(Color("4a9a5a")))

# --------------------------------------------------------------- gramophone
func _gramophone() -> void:
	gram = Mk.group(self, "gramophone")
	var wl := Mk.tex(Tex.wood("8a5a3a"), 3.0)
	var wd := Mk.tex(Tex.wood("4a2a1c"), 3.0)
	var gx := 2.4
	Mk.bb(gram, gx - 0.45, 0.7, 0.12, gx + 0.45, 0.75, 0.6, wl)
	for lx in [-0.4, 0.4]:
		for lz in [0.16, 0.56]:
			Mk.bb(gram, gx + lx - 0.025, 0, lz - 0.025, gx + lx + 0.025, 0.7, lz + 0.025, wd)
	Mk.bb(gram, gx - 0.26, 0.75, 0.2, gx + 0.26, 0.97, 0.56, Mk.tex(Tex.wood("6b3f2a"), 3.0))
	record = Mk.cy(gram, gx - 0.02, 0.97, 0.38, 0.2, 0.2, 0.012, Mk.flat(Color("14151f"), 0.3), 24)
	Mk.cy(record, 0.0, 0.0, 0.0, 0.06, 0.06, 0.016, Mk.flat(Color("b13e53")), 12, false)
	Mk.bb(gram, gx + 0.1, 0.98, 0.3, gx + 0.2, 1.0, 0.34, Mk.flat(Color("c8c8d0"), 0.3))
	var horn := Mk.cy(gram, gx + 0.3, 1.2, 0.36, 0.28, 0.03, 0.5, Mk.flat(Color("d09a3a"), 0.28), 18)
	horn.rotation_degrees = Vector3(0, 0, -48)
	Mk.cy(gram, gx + 0.2, 0.97, 0.36, 0.035, 0.035, 0.12, Mk.flat(Color("d09a3a"), 0.28), 10)
	# a crate of records on the floor below, and a few loose discs
	var crate := Mk.tex(Tex.wood("6b3f2a"), 3.0)
	Mk.bb(gram, gx - 0.34, 0.0, 0.3, gx + 0.14, 0.3, 0.36, crate)
	Mk.bb(gram, gx - 0.34, 0.0, 0.62, gx + 0.14, 0.3, 0.68, crate)
	Mk.bb(gram, gx - 0.34, 0.0, 0.3, gx - 0.28, 0.3, 0.68, crate)
	Mk.bb(gram, gx + 0.08, 0.0, 0.3, gx + 0.14, 0.3, 0.68, crate)
	var sleeves := [Color("b13e53"), Color("3b5dc9"), Color("38b764"), Color("ffcd75"), Color("5d275d"), Color("ef7d57"), Color("73eff7")]
	for i in 9:
		var sl := Mk.cy(gram, gx - 0.25 + i * 0.045, 0.012, 0.49, 0.145, 0.145, 0.012, Mk.flat(sleeves[i % sleeves.size()], 0.6), 18)
		sl.rotation_degrees = Vector3(90, 0, 0)
		sl.position = Vector3(gx - 0.25 + i * 0.045, 0.17 + (i % 2) * 0.02, 0.49)
		var rp := Mk.cy(gram, 0, 0, 0, 0.12, 0.12, 0.004, Mk.flat(Color("14151f"), 0.3), 18, false)
		rp.rotation_degrees = Vector3(90, 0, 0)
		rp.position = Vector3(gx - 0.25 + i * 0.045, 0.2 + (i % 2) * 0.02, 0.5)
	for i in 3:
		var dsc := Mk.cy(gram, gx + 0.42 + i * 0.03, 0.0 + i * 0.012, 0.3 + i * 0.05, 0.17, 0.17, 0.012, Mk.flat(Color("14151f"), 0.3), 22)
		dsc.rotation_degrees.y = i * 25.0
		Mk.cy(gram, gx + 0.42 + i * 0.03, 0.012 + i * 0.012, 0.3 + i * 0.05, 0.055, 0.055, 0.004, Mk.flat(sleeves[(i * 2) % sleeves.size()], 0.5), 12, false)

# ----------------------------------------------------------------- computer
func _computer() -> void:
	var cx := 4.1
	var root := Mk.group(self, "comp", 3.55, 0.0, 0.45)
	root.rotation_degrees.y = 52.0
	var inner := Mk.group(root, "inner", -4.1, 0.0, -0.45)
	var beige := Mk.tex(Tex.metal("c8c0a8"), 2.0)
	var wl := Mk.tex(Tex.wood("8a5a3a"), 3.0)
	var wd := Mk.tex(Tex.wood("5a3a24"), 3.0)
	Mk.bb(inner, cx - 0.85, 0.72, 0.1, cx + 0.85, 0.77, 0.8, wl)
	Mk.bb(inner, cx - 0.82, 0.0, 0.14, cx - 0.76, 0.72, 0.76, wd)
	Mk.bb(inner, cx + 0.3, 0.0, 0.14, cx + 0.82, 0.72, 0.76, wd)
	for d in 3:
		Mk.bb(inner, cx + 0.34, 0.08 + d * 0.2, 0.76, cx + 0.78, 0.24 + d * 0.2, 0.79, wl)
		Mk.sp(inner, cx + 0.56, 0.16 + d * 0.2, 0.82, 0.02, Mk.flat(Color("d8a040"), 0.3), false)
	# monitor, PC tower, keyboard, mouse
	Mk.bb(inner, cx - 0.2, 0.77, 0.36, cx + 0.2, 0.8, 0.62, beige)
	Mk.bb(inner, cx - 0.05, 0.8, 0.46, cx + 0.05, 0.95, 0.54, beige)
	Mk.bb(inner, cx - 0.4, 0.93, 0.34, cx + 0.4, 1.46, 0.58, beige)
	Mk.bb(inner, cx - 0.36, 0.97, 0.58, cx + 0.36, 1.42, 0.6, Mk.flat(Color("14181c"), 0.3))
	for i in 4:
		var img := Image.create(32, 22, false, Image.FORMAT_RGBA8)
		for y in 22:
			for xx in 32:
				var c := Color("14284a")
				if y >= 17:
					c = Color("3a8a3a") if (xx + i) % 6 > 1 else Color("2a6a2a")
				if absi(xx - (4 + i * 6)) < 2 and y > 11 and y < 17:
					c = Color("ffcd75")
				if Vector2(xx - 24, y - (8 + (i % 2) * 2)).length() < 2.2:
					c = Color("ffe070")
				if xx % 9 == (i + 3) % 9 and y == 4:
					c = Color("e0e0ff")
				img.set_pixel(xx, y, c)
		comp_mats.append(Mk.uvtex(ImageTexture.create_from_image(img), Color.WHITE, 1.3, 0.3))
	comp_off = Mk.flat(Color("0a1418"), 0.2)
	comp_screen = Mk.quad(inner, cx, 1.2, 0.605, 0.66, 0.44, comp_off)
	Mk.bb(inner, cx + 0.5, 0.77, 0.3, cx + 0.76, 1.2, 0.7, beige)
	Mk.sp(inner, cx + 0.52, 1.1, 0.71, 0.012, Mk.glass(Color("60ff80"), 2.0), false)
	var kb := Mk.bb(inner, cx - 0.32, 0.77, 0.66, cx + 0.22, 0.79, 0.76, beige)
	for r in 3:
		for k in 13:
			Mk.bx(inner, cx - 0.29 + k * 0.04, 0.79, 0.675 + r * 0.028, 0.032, 0.008, 0.022, Mk.flat(Color("a8a290") if (r + k) % 3 else Color("8a8678"), 0.6), false)
	Mk.bb(inner, cx + 0.3, 0.77, 0.68, cx + 0.42, 0.78, 0.8, Mk.flat(Color("2a3a5a"), 0.8))
	Mk.bb(inner, cx + 0.34, 0.78, 0.7, cx + 0.4, 0.795, 0.76, beige)
	Mk.cy(inner, cx - 0.62, 0.77, 0.4, 0.05, 0.05, 0.1, Mk.flat(Color("b13e53"), 0.4), 12)
	for i in 3:
		Mk.quad(inner, cx - 0.3 + i * 0.12, 1.5 + (i % 2) * 0.04, 0.585, 0.07, 0.07, Mk.flat([Color("ffe070"), Color("ff9ab0"), Color("9ae0ff")][i], 0.9))
	comp_light = Mk.omni(inner, cx, 1.2, 1.0, Color(0.5, 0.75, 1.0), 0.0, 3.4, false)

# the swivel chair at the computer: seat facing the desk (to the left), back on the right
func _comp_chair() -> void:
	var seat_m := Mk.tex(Tex.wood("2a5a5a"), 3.0)
	var sx := 4.45
	var sz := 1.25
	Mk.bb(self, sx - 0.3, 0.28, sz - 0.3, sx + 0.3, 0.35, sz + 0.3, seat_m)
	Mk.bb(self, sx + 0.22, 0.35, sz - 0.3, sx + 0.3, 0.98, sz + 0.3, seat_m)
	Mk.cy(self, sx, 0.0, sz, 0.035, 0.035, 0.28, Mk.flat(Color("2a2a34"), 0.4), 8)
	for k in 5:
		var a := k * TAU / 5.0
		Mk.bb(self, sx + cos(a) * 0.12 - 0.02, 0.0, sz + sin(a) * 0.12 - 0.02, sx + cos(a) * 0.26 + 0.02, 0.04, sz + sin(a) * 0.26 + 0.02, Mk.flat(Color("2a2a34"), 0.4))

# a deep armchair in front of the bookshelf, for long reads; seat faces right
func _armchair() -> void:
	var fab := Mk.tex(Tex.wood("7a2a3a"), 2.5)
	var fab_l := Mk.tex(Tex.wood("9a3a4a"), 2.5)
	var ax := 1.1
	var az := 0.78
	Mk.bb(self, ax - 0.46, 0.08, az - 0.42, ax + 0.46, 0.24, az + 0.42, fab)
	Mk.bb(self, ax - 0.36, 0.24, az - 0.34, ax + 0.4, 0.36, az + 0.34, fab_l)
	Mk.bb(self, ax - 0.46, 0.24, az - 0.42, ax - 0.24, 1.05, az + 0.42, fab)
	Mk.bb(self, ax - 0.43, 0.9, az - 0.3, ax - 0.2, 1.12, az + 0.3, fab_l)
	for sd in [-1.0, 1.0]:
		Mk.bb(self, ax - 0.42, 0.24, az + sd * 0.42 - (0.0 if sd > 0 else 0.14), ax + 0.42, 0.58, az + sd * 0.42 + (0.14 if sd > 0 else 0.0), fab)
		Mk.cy(self, ax, 0.16, az + sd * 0.35, 0.07, 0.07, 0.84, fab_l, 10).rotation_degrees = Vector3(0, 0, 90)
	for lx in [-0.4, 0.4]:
		for lz in [-0.36, 0.36]:
			Mk.cy(self, ax + lx, 0.0, az + lz, 0.035, 0.03, 0.09, Mk.tex(Tex.wood("2a160e"), 3.0), 8)
	# a reading lamp behind it
	Mk.cy(self, 0.38, 0.0, 1.0, 0.14, 0.14, 0.04, Mk.flat(Color("2a2a34"), 0.4), 12)
	Mk.cy(self, 0.38, 0.04, 1.0, 0.012, 0.012, 1.5, Mk.flat(Color("8a8a96"), 0.4), 6, false)
	Mk.cy(self, 0.38, 1.44, 1.0, 0.2, 0.09, 0.2, Mk.flat(Color("e8c070"), 0.6), 14)
	read_lamp = Mk.omni(self, 0.55, 1.4, 1.1, Color(1.0, 0.85, 0.55), 0.0, 4.0, false)

func seat(x: Dictionary) -> Dictionary:
	if not x["run"]:
		return {}
	match String(x["vis"]):
		"book":
			return {"pos": Vector3(1.14, 0.0, 0.78), "face": 1}
		"game":
			return {"pos": Vector3(4.47, 0.0, 1.25), "face": -1}
		"chess":
			return {"pos": Vector3(9.3 - 0.95, 0.12, 0.5), "face": 1}
	return {}


# ----------------------------------------------------------------------- TV
func _tv() -> void:
	var wd := Mk.tex(Tex.wood("4a2a1c"), 3.0)
	var tx := 5.5
	Mk.bb(self, tx - 0.6, 0, 0.1, tx + 0.6, 0.62, 0.62, Mk.tex(Tex.wood("6b3f2a"), 3.0))
	Mk.bb(self, tx - 0.56, 0.62, 0.08, tx + 0.56, 1.42, 0.7, Mk.flat(Color("2a2a34"), 0.6))
	Mk.bb(self, tx - 0.5, 0.7, 0.7, tx + 0.5, 1.34, 0.72, Mk.flat(Color("1a1a22"), 0.5))
	for i in 4:
		var col: Array = [[Color("3a8ad0"), Color("ffe0a0")], [Color("d07a4a"), Color("ffd070")], [Color("2a8a6a"), Color("90e0a0")], [Color("5a3a8a"), Color("c8a0ff")]][i]
		var img := Image.create(32, 24, false, Image.FORMAT_RGBA8)
		for y in 24:
			var c: Color = (col[0] as Color).lerp(col[1], float(y) / 23.0)
			for x in 32:
				var cc := c
				if absf(x - (6 + i * 7)) + absf(y - 12) < 5:
					cc = Color.WHITE
				if y > 18:
					cc = cc.darkened(0.25)
				img.set_pixel(x, y, cc)
		tv_mats.append(Mk.uvtex(ImageTexture.create_from_image(img), Color.WHITE, 1.4, 0.4))
	tv_off_mat = Mk.flat(Color("0f1a1c"), 0.2)
	tv_screen = Mk.quad(self, tx, 1.02, 0.735, 0.88, 0.58, tv_off_mat)
	Mk.cy(self, tx, 1.42, 0.38, 0.0, 0.0, 0.01, Mk.flat(Color.BLACK), 4, false)
	var an1 := Mk.cy(self, tx - 0.05, 1.42, 0.4, 0.008, 0.008, 0.5, Mk.flat(Color("b0b0c0"), 0.3), 5, false)
	an1.rotation_degrees = Vector3(0, 0, 35)
	var an2 := Mk.cy(self, tx + 0.05, 1.42, 0.4, 0.008, 0.008, 0.5, Mk.flat(Color("b0b0c0"), 0.3), 5, false)
	an2.rotation_degrees = Vector3(0, 0, -35)
	tv_light = Mk.omni(self, tx, 1.0, 1.1, Color(0.5, 0.75, 1.0), 0.0, 3.2, false)

# -------------------------------------------------------------------- clock
func _clock() -> void:
	var cx := 6.46
	var cyy := 2.35
	var face := Mk.cy(self, cx, cyy, 0.03, 0.24, 0.24, 0.05, Mk.flat(Color("e8e0c8"), 0.5), 24)
	face.rotation_degrees = Vector3(90, 0, 0)
	face.position = Vector3(cx, cyy, 0.045)
	var rim := Mk.cy(self, cx, cyy, 0.03, 0.27, 0.27, 0.04, Mk.flat(Color("5a3a24")), 24)
	rim.rotation_degrees = Vector3(90, 0, 0)
	rim.position = Vector3(cx, cyy, 0.035)
	for k in 12:
		var a := k * TAU / 12.0
		Mk.bx(self, cx + sin(a) * 0.2, cyy + cos(a) * 0.2 - 0.01, 0.075, 0.012, 0.025 if k % 3 == 0 else 0.014, 0.004, Mk.flat(Color("2a2a34")), false)
	clock_h = Mk.group(self, "clock_h", cx, cyy, 0.085)
	Mk.bx(clock_h, 0, 0, 0, 0.018, 0.12, 0.006, Mk.flat(Color("1a1a22")), false)
	clock_m = Mk.group(self, "clock_m", cx, cyy, 0.092)
	Mk.bx(clock_m, 0, 0, 0, 0.012, 0.18, 0.006, Mk.flat(Color("b13e53")), false)

# ------------------------------------------------------------------ cabinet
func _cabinet() -> void:
	var cx := 7.42
	var w1 := Mk.tex(Tex.wood("8a5a3a"), 3.0)
	var w2 := Mk.tex(Tex.wood("6b3f2a"), 3.0)
	Mk.bb(self, cx - 0.55, 0.0, 0.05, cx + 0.55, 0.92, 0.55, w2)
	Mk.bb(self, cx - 0.58, 0.92, 0.03, cx + 0.58, 0.97, 0.58, w1)
	for d in 3:
		var y0 := 0.08 + d * 0.28
		Mk.bb(self, cx - 0.5, y0, 0.55, cx + 0.5, y0 + 0.25, 0.58, w1)
		Mk.sp(self, cx, y0 + 0.125, 0.61, 0.025, Mk.flat(Color("d8a040"), 0.3))
	# a cup of tea, long gone cold - it still steams
	Mk.cy(self, cx - 0.35, 0.97, 0.3, 0.07, 0.07, 0.01, Mk.flat(Color("e8e0d0"), 0.3), 14)
	Mk.cy(self, cx - 0.35, 0.98, 0.3, 0.045, 0.05, 0.075, Mk.flat(Color("e8e0d0"), 0.3), 14)
	Mk.cy(self, cx - 0.35, 1.04, 0.3, 0.04, 0.04, 0.008, Mk.flat(Color("7a4a2a"), 0.4), 14, false)
	Mk.bx(self, cx - 0.29, 1.0, 0.3, 0.025, 0.04, 0.012, Mk.flat(Color("e8e0d0"), 0.3), false)
	steam = CPUParticles3D.new()
	steam.amount = 14
	steam.lifetime = 2.6
	steam.position = Vector3(cx - 0.35, 1.08, 0.3)
	steam.gravity = Vector3(0, 0.12, 0)
	steam.direction = Vector3(0, 1, 0)
	steam.spread = 12.0
	steam.initial_velocity_min = 0.05
	steam.initial_velocity_max = 0.1
	steam.scale_amount_min = 0.6
	steam.scale_amount_max = 1.6
	var sm := QuadMesh.new()
	sm.size = Vector2(0.05, 0.05)
	steam.mesh = sm
	var smat := StandardMaterial3D.new()
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smat.albedo_texture = Tex.radial(Color(1, 1, 1, 0.5), 1.0)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	steam.material_override = smat
	add_child(steam)
	# vase with a flower
	Mk.cy(self, cx + 0.3, 0.97, 0.3, 0.07, 0.05, 0.22, Mk.flat(Color("3a8a8a"), 0.35), 14)
	for k in 3:
		var st := Mk.cy(self, cx + 0.3 + (k - 1) * 0.02, 1.15, 0.3, 0.004, 0.004, 0.25 + k * 0.04, Mk.flat(Color("3a8a4a")), 5, false)
		st.rotation_degrees = Vector3(0, 0, (k - 1) * 10)
	Mk.sp(self, cx + 0.3, 1.43, 0.3, 0.035, Mk.flat(Color("d04a5a"), 0.5), false)

# -------------------------------------------------------------------- table
func _table() -> void:
	var cx := 9.3
	var w1 := Mk.tex(Tex.wood("8a5a3a"), 3.0)
	var w2 := Mk.tex(Tex.wood("5a3a24"), 3.0)
	Mk.bb(self, cx - 0.7, 0.72, 0.1, cx + 0.7, 0.77, 0.9, w1)
	Mk.bb(self, cx - 0.62, 0.65, 0.16, cx + 0.62, 0.72, 0.84, w2)
	for lx in [-0.62, 0.6]:
		for lz in [0.16, 0.82]:
			Mk.bb(self, cx + lx - 0.03, 0, lz - 0.03, cx + lx + 0.03, 0.72, lz + 0.03, w2)
	# chairs
	for side in 2:
		var chx: float = cx - 0.95 if side == 0 else cx + 0.95
		Mk.bb(self, chx - 0.2, 0.42, 0.3, chx + 0.2, 0.46, 0.7, w1)
		for lx in [-0.18, 0.18]:
			for lz in [0.32, 0.68]:
				Mk.bb(self, chx + lx - 0.015, 0, lz - 0.015, chx + lx + 0.015, 0.42, lz + 0.015, w2)
		var back_x: float = chx - 0.2 if side == 0 else chx + 0.17
		Mk.bb(self, back_x, 0.46, 0.3, back_x + 0.03, 0.95, 0.7, w2)
		for k in 3:
			Mk.bb(self, back_x - 0.005, 0.55 + k * 0.14, 0.32, back_x + 0.035, 0.6 + k * 0.14, 0.68, w1)
	# chess set (appears once found)
	chess = Mk.group(self, "chess")
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	for y in 8:
		for x in 8:
			img.set_pixel(x, y, Color("e8dcb8") if (x + y) % 2 == 0 else Color("3a2418"))
	Mk.bb(chess, cx - 0.22, 0.77, 0.3, cx + 0.22, 0.785, 0.72, Mk.uvtex(ImageTexture.create_from_image(img), Color.WHITE, 0.0, 0.5))
	for i in 8:
		var white := i % 2 == 0
		var pc := Color("f0ece0") if white else Color("1a1a22")
		var px := cx - 0.18 + (i * 3 % 8) * 0.05
		var pz := 0.36 + (i % 4) * 0.08 + (0.1 if not white else 0.0)
		Mk.cy(chess, px, 0.785, pz, 0.014, 0.014, 0.04, Mk.flat(pc, 0.3), 8)
		Mk.sp(chess, px, 0.83, pz, 0.014, Mk.flat(pc, 0.3), true)

# ------------------------------------------------------------------ picture
func _picture() -> void:
	var img := Image.create(32, 24, false, Image.FORMAT_RGBA8)
	for y in 24:
		for x in 32:
			var c := Color("5a8ab0").lerp(Color("cfe4f0"), float(y) / 14.0) if y < 15 else Color("2d5a3a").lerp(Color("4a7a40"), Tex.n2(x, y, 3))
			if Vector2(x - 22, y - 7).length() < 3.0:
				c = Color("ffd070")
			if y >= 10 and y < 16 and absf(x - 8) + (y - 10) * 1.6 < 8:
				c = Color("3a6a50")
			img.set_pixel(x, y, c)
	Mk.bb(self, 2.18, 1.95, 0.0, 2.82, 2.45, 0.05, Mk.tex(Tex.wood("4a2a1c"), 3.0))
	Mk.quad(self, 2.5, 2.2, 0.056, 0.54, 0.4, Mk.uvtex(ImageTexture.create_from_image(img), Color.WHITE, 0.0, 0.7))

# --------------------------------------------------------------------- lamp
func _lamp() -> void:
	var lx := 8.0
	Mk.cy(self, lx, 2.72, 1.55, 0.008, 0.008, 0.48, Mk.flat(Color("1a1a22")), 5, false)
	Mk.cy(self, lx, 2.52, 1.55, 0.2, 0.05, 0.2, Mk.flat(Color("3a5a4a"), 0.5), 16)
	Mk.sp(self, lx, 2.5, 1.55, 0.06, Mk.glass(Color("fff0b0"), 2.2), false)
	lamp = Mk.omni(self, lx, 2.42, 1.55, Color(1.0, 0.82, 0.52), 1.6, 7.5, true)

# ---------------------------------------------------------------------- rug
func _rug() -> void:
	Mk.quad(self, 5.9, 0.006, 1.95, 5.2, 2.2, Mk.uvtex(Tex.rug(), Color.WHITE, 0.0, 0.95), Vector3(-90, 0, 0))

# ------------------------------------------------- foreground (blurred) props
func _foreground() -> void:
	# potted plant at the left end, chair at the right end, close to the camera
	var pot := Mk.cy(self, 0.7, 0.0, 3.5, 0.28, 0.22, 0.5, Mk.flat(Color("7a3a24"), 0.7), 14)
	pot.name = "fg_pot"
	var leaf := Mk.flat(Color("2a6a3a"), 0.6)
	for i in 9:
		var a := i * TAU / 9.0
		var l := Mk.bx(self, 0.7 + cos(a) * 0.08, 0.5, 3.5 + sin(a) * 0.08, 0.04, 0.9 + Tex.n2(i, 2, 5) * 0.4, 0.2, leaf)
		l.rotation_degrees = Vector3(sin(a) * 28.0, rad_to_deg(a), cos(a) * 28.0)
	var w2 := Mk.tex(Tex.wood("4a2a1c"), 3.0)
	Mk.bb(self, 11.9, 0, 3.3, 11.96, 1.1, 3.36, w2)
	Mk.bb(self, 12.4, 0, 3.3, 12.46, 1.1, 3.36, w2)
	Mk.bb(self, 11.88, 0.5, 3.28, 12.48, 0.56, 3.5, w2)
	for k in 4:
		Mk.bb(self, 11.9, 0.62 + k * 0.12, 3.3, 12.46, 0.68 + k * 0.12, 3.34, w2)

# ------------------------------------------------------------------- update
func update(x: Dictionary, _dt: float) -> void:
	var t: float = x["t"]
	var day: float = x["day"]
	var vis: String = x["vis"]
	var run: bool = x["run"]
	var sh: float = SkyKit.sun_h(day)
	var night: float = SkyKit.night_amt(day)
	# sun / moon through the window
	if sh > 0.02:
		var el := deg_to_rad(10.0 + sh * 46.0)
		aim_sun(Vector3(-0.32, -sin(el), cos(el)))
		sun.light_energy = lerpf(0.0, 2.8, clampf(sh * 1.7, 0.0, 1.0))
		sun.light_color = Color(1.0, 0.72, 0.45).lerp(Color(1.0, 0.96, 0.88), clampf(sh * 1.6, 0.0, 1.0))
	else:
		aim_sun(Vector3(-0.15, -0.55, 0.82))
		sun.light_energy = 0.55 * clampf(-sh * 2.0, 0.0, 1.0)
		sun.light_color = Color(0.55, 0.68, 1.0)
	env.ambient_light_color = Color(0.5, 0.56, 0.72).lerp(Color(0.12, 0.15, 0.3), night)
	env.ambient_light_energy = lerpf(0.62, 0.7, night)
	room_fill.light_energy = lerpf(0.2, 0.1, night)
	win_glow.light_energy = clampf(sh * 1.4, 0.0, 1.0) * 0.5
	# window sky
	var a: StandardMaterial3D = sky_a
	var top := SkyKit.sky_top(day)
	var bot := SkyKit.sky_bot(day)
	a.albedo_color = top
	sky_b.albedo_color = bot
	# lamp: a faint, living flicker
	lamp.light_energy = 1.55 + sin(t * 9.0) * 0.015 + sin(t * 23.0) * 0.01
	# clock keeps game time
	clock_h.rotation_degrees.z = -day * 720.0
	clock_m.rotation_degrees.z = -day * 24.0 * 360.0
	# reading lamp comes up while he reads
	read_lamp.light_energy = 1.1 if (vis == "book" and run) else 0.15
	# computer
	var gaming := vis == "game" and run
	if gaming:
		comp_screen.material_override = comp_mats[int(t * 3.0) % comp_mats.size()]
		comp_light.light_energy = 0.6 + 0.15 * sin(t * 12.0)
	else:
		comp_screen.material_override = comp_off
		comp_light.light_energy = 0.0
	# television
	var tv_on := vis == "tv" and run
	if tv_on:
		tv_screen.material_override = tv_mats[int(t * 0.6) % tv_mats.size()]
		tv_light.light_energy = 0.7 + 0.15 * sin(t * 30.0)
	else:
		tv_screen.material_override = tv_off_mat
		tv_light.light_energy = 0.0
	# things that appear once found
	gram.visible = true
	show_if(chess, flag(x, "found_chess"))
	show_if(almanac, flag(x, "found_almanac"))
	var open: bool = x["can_leave"]
	show_if(door_closed, not open)
	show_if(door_open, open)
	show_if(outside, open)
	if record != null:
		record.rotation_degrees.y += 3.0 if (vis == "music" and run) else 0.0
	dust.emitting = sh > 0.1
	dust.visible = sh > 0.1
