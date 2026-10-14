class_name Kit
extends RefCounted
# Reusable outdoor building blocks for the 3D dioramas.

static func _rh(x: float, seed_v: float) -> float:
	var h := 0.5 + 0.5 * sin(x * 0.07 + seed_v) * cos(x * 0.031 + seed_v * 2.0)
	h += 0.3 * (Tex.vn(x * 0.12, seed_v, int(seed_v)) - 0.5)
	h += 0.12 * (Tex.vn(x * 0.5, seed_v * 3.0, int(seed_v) + 3) - 0.5)
	return maxf(h, 0.0)

# a mountain/hill silhouette: a strip of triangles facing the camera
static func ridge(s: SceneBase, z: float, base_y: float, amp: float, seed_v: float, col: Color, haze: float, snow: bool = false, x0: float = -70.0, x1: float = 90.0) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := int((x1 - x0) / 1.5)
	for i in n:
		var xa := x0 + i * 1.5
		var xb := xa + 1.5
		var ha := base_y + _rh(xa, seed_v) * amp
		var hb := base_y + _rh(xb, seed_v) * amp
		var rock := Color(0.62, 0.62, 0.66)
		var ca := rock
		var cb := rock
		var ta := rock
		var tb := rock
		if snow:
			ta = rock.lerp(Color.WHITE, clampf((ha - base_y - amp * 0.62) / (amp * 0.2), 0.0, 1.0))
			tb = rock.lerp(Color.WHITE, clampf((hb - base_y - amp * 0.62) / (amp * 0.2), 0.0, 1.0))
		var bot := base_y - 8.0
		var pts := [[Vector3(xa, bot, z), ca], [Vector3(xb, bot, z), cb], [Vector3(xb, hb, z), tb],
			[Vector3(xa, bot, z), ca], [Vector3(xb, hb, z), tb], [Vector3(xa, ha, z), ta]]
		for p in pts:
			st.set_normal(Vector3(0, 0, 1))
			st.set_color(p[1])
			st.add_vertex(p[0])
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	s.add_child(mi)
	s.ridges.append([m, col, haze, snow])
	return mi

static func retint_ridges(s: SceneBase, day: float) -> void:
	var bot := SkyKit.sky_bot(day)
	var night := SkyKit.night_amt(day)
	var sh := clampf(SkyKit.sun_h(day) * 1.5 + 0.5, 0.15, 1.0)
	for r in s.ridges:
		var m: StandardMaterial3D = r[0]
		var base: Color = r[1]
		var haze: float = r[2]
		var c := base.lerp(bot, haze).darkened(night * 0.55)
		var f := 1.4 * (0.5 + 0.5 * sh)
		m.albedo_color = Color(c.r * f, c.g * f, c.b * f)

static func ground(parent: Node, x0: float, x1: float, z0: float, z1: float, mat: Material, top: float = 0.0) -> MeshInstance3D:
	return Mk.bb(parent, x0, top - 0.6, z0, x1, top, z1, mat, true)

static func oak(parent: Node, x: float, z: float, h: float, leaf_hex: String = "2f7a3a", seed_v: int = 1) -> Node3D:
	var g := Mk.group(parent, "oak", x, 0.0, z)
	var bark := Mk.tex(Tex.bark(), 2.5)
	Mk.cy(g, 0, 0, 0, h * 0.075, h * 0.05, h * 0.62, bark, 10)
	var leaf := Mk.tex(Tex.leaves(leaf_hex), 2.2)
	var r := h * 0.27
	for i in 8:
		var a := i * TAU / 8.0 + Tex.n2(i, seed_v, 3)
		var rr := r * (0.5 + 0.55 * Tex.n2(i, seed_v, 4))
		Mk.sp(g, cos(a) * r * 0.75, h * (0.62 + 0.2 * Tex.n2(i, seed_v, 5)), sin(a) * r * 0.75, rr, leaf, true, 0.85)
	Mk.sp(g, 0, h * 0.82, 0, r * 1.05, leaf, true, 0.9)
	return g

static func pine(parent: Node, x: float, z: float, h: float, leaf_hex: String = "245a34") -> Node3D:
	var g := Mk.group(parent, "pine", x, 0.0, z)
	Mk.cy(g, 0, 0, 0, h * 0.04, h * 0.04, h * 0.3, Mk.tex(Tex.bark(), 2.5), 8)
	var leaf := Mk.tex(Tex.leaves(leaf_hex), 2.2)
	for k in 4:
		var rr := h * (0.26 - k * 0.05)
		Mk.cy(g, 0, h * (0.2 + k * 0.2), 0, rr, 0.01, h * 0.34, leaf, 9)
	return g

static func fence(parent: Node, x0: float, x1: float, z: float, h: float = 0.9) -> void:
	var w := Mk.tex(Tex.wood("8a5a3a"), 3.0)
	var x := x0
	while x <= x1:
		Mk.bb(parent, x - 0.05, 0, z - 0.04, x + 0.05, h, z + 0.04, w)
		x += 0.9
	Mk.bb(parent, x0, h * 0.35, z - 0.03, x1, h * 0.35 + 0.07, z + 0.03, w)
	Mk.bb(parent, x0, h * 0.72, z - 0.03, x1, h * 0.72 + 0.07, z + 0.03, w)

static func tufts(parent: Node, x0: float, x1: float, z0: float, z1: float, count: int, seed_v: int, hex: String = "3a8a40") -> void:
	var t := Tex.tuft(hex)
	for i in count:
		var sp := Mk.sprite(parent, t, x0 + Tex.n2(i, seed_v, 1) * (x1 - x0), 0.0, z0 + Tex.n2(i, seed_v, 2) * (z1 - z0), 0.03 + Tex.n2(i, seed_v, 3) * 0.02, true, true)
		sp.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD

static func flowers(parent: Node, x0: float, x1: float, z0: float, z1: float, count: int, seed_v: int) -> void:
	var cols := [Color("e04a6a"), Color("ffcd75"), Color("c8a0ff"), Color("ffffff")]
	for i in count:
		var col: Color = cols[i % cols.size()]
		Mk.sprite(parent, Tex.flower(col), x0 + Tex.n2(i, seed_v, 1) * (x1 - x0), 0.0, z0 + Tex.n2(i, seed_v, 2) * (z1 - z0), 0.032, true, true)

static func rock(parent: Node, x: float, z: float, r: float, col_hex: String = "5a6270", seed_v: int = 1) -> Node3D:
	var g := Mk.group(parent, "rock", x, 0.0, z)
	var m := Mk.tex(Tex.flagstone(col_hex), 1.5)
	for i in 3:
		var rr := r * (0.5 + 0.5 * Tex.n2(i, seed_v, 2))
		Mk.sp(g, (Tex.n2(i, seed_v, 3) - 0.5) * r, rr * 0.4, (Tex.n2(i, seed_v, 4) - 0.5) * r * 0.6, rr, m, true, 0.7)
	return g

static func building(parent: Node, x: float, z: float, w: float, d: float, h: float, wall: Material, roof_hex: String = "8a3a3a", roof_h: float = -1.0) -> Node3D:
	var g := Mk.group(parent, "building", x, 0.0, z)
	Mk.bx(g, 0, 0, 0, w, h, d, wall)
	var rh := roof_h if roof_h > 0.0 else w * 0.32
	var prism := PrismMesh.new()
	prism.size = Vector3(w + 0.3, rh, d + 0.3)
	var mi := MeshInstance3D.new()
	mi.mesh = prism
	mi.material_override = Mk.tex(Tex.shingles(roof_hex), 1.5)
	mi.position = Vector3(0, h + rh / 2.0, 0)
	g.add_child(mi)
	return g
