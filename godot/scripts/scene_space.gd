class_name SceneSpace
extends SceneBase
# Eras 6 and 7: a slab of rock drifting in space, then in the dark. `dark` selects the era.

var dark := false
var slab_mat: StandardMaterial3D
var debris: Array = []
var beacons: Array = []
var beacon_x: Array = []
var nebula: Node3D
var star: MeshInstance3D
var star_mat: StandardMaterial3D
var star_light: OmniLight3D
var planet: MeshInstance3D
var dust_ring: CPUParticles3D
var comet: Node3D
var comet_head: Sprite3D
var comet_trail: CPUParticles3D
var crystal: Node3D
var crystal_light: OmniLight3D
var rings: Array = []
var holes: Array = []
var photon: MeshInstance3D
var photon_light: OmniLight3D
var core_light: OmniLight3D
var _orbit := 6.0

func build() -> void:
	outdoor = false
	width_m = 10.0
	hero_z = 1.4
	cam_dist = 12.0
	cam_h = 3.4
	look_y = 1.5
	cam_min = 4.9
	cam_max = 5.2
	marker_y = 2.6
	make_env(Color("02030a"), Color(0.45, 0.5, 0.75), 0.9)
	make_sun(1.0)
	sun.light_energy = 0.0
	sun.shadow_enabled = false
	# the slab we float on
	slab_mat = Mk.tex(Tex.rockface("3a3050"), 1.0)
	Mk.bb(self, -4.0, -0.9, -2.2, 14.0, 0.0, 4.2, slab_mat)
	Mk.bb(self, -3.6, -1.6, -1.8, 13.6, -0.9, 3.8, Mk.tex(Tex.rockface("2a2440"), 1.0))
	Mk.bb(self, -2.5, -2.2, -1.2, 12.0, -1.6, 3.0, Mk.tex(Tex.rockface("221c34"), 1.0))
	for i in 9:
		var d := Mk.sp(self, -5.0 + i * 2.4 + Tex.n2(i, 1, 33), -2.0 - Tex.n2(i, 2, 33) * 2.0, 1.0 + Tex.n2(i, 3, 33) * 3.0, 0.2 + Tex.n2(i, 4, 33) * 0.4, Mk.tex(Tex.rockface("3a3050"), 1.5), true, 0.7)
		d.set_meta("i", i)
		debris.append(d)
	# hotspot beacons: pillars of faint light
	var xs: Array = [0.84, 2.7, 3.9, 5.25, 7.5, 9.3] if not dark else [1.14, 3.0, 5.7, 7.86, 9.36]
	for bxm in xs:
		var g := Mk.group(self, "beacon", bxm, 0.0, hero_z)
		Mk.cy(g, 0, 0, 0, 0.012, 0.012, 2.0, Mk.glass(Color("73eff7") if not dark else Color("8a7ab0"), 1.0), 5, false)
		Mk.sp(g, 0, 2.05, 0, 0.05, Mk.glass(Color("b8f8ff"), 1.4), false)
		beacons.append(g)
		beacon_x.append(bxm)
	core_light = Mk.omni(self, 4.9, 2.6, 3.2, Color(0.8, 0.85, 1.0), 0.9, 16.0, false)
	if dark:
		_build_dark()
	else:
		_build_stars()

func _build_stars() -> void:
	# a dark nebula
	nebula = Mk.group(self, "nebula")
	for i in 16:
		var a := Tex.n2(i, 1, 41) * TAU
		var r := 4.0 + Tex.n2(i, 2, 41) * 10.0
		var s := Mk.sprite(nebula, Tex.radial(Color.from_hsv(0.88 + Tex.n2(i, 3, 41) * 0.1, 0.55, 0.9, 0.5), 0.8), 1.5 + cos(a) * r, 4.0 + sin(a) * r * 0.5, -40.0 - Tex.n2(i, 4, 41) * 14.0, 0.25 + Tex.n2(i, 5, 41) * 0.25, true, false)
		s.offset = Vector2.ZERO
	# the young star and its world
	star_mat = Mk.glass(Color("ffe9a0"), 2.2)
	star = Mk.sp(self, 7.0, 5.8, -22.0, 1.2, star_mat, false)
	star_light = Mk.omni(self, 7.0, 5.8, -20.0, Color(1.0, 0.92, 0.7), 0.0, 90.0, false)
	var pm := StandardMaterial3D.new()
	pm.albedo_texture = _planet_tex()
	pm.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	pm.roughness = 0.8
	planet = Mk.sp(self, 0, 0, 0, 0.5, pm, false)
	dust_ring = CPUParticles3D.new()
	dust_ring.amount = 160
	dust_ring.lifetime = 6.0
	dust_ring.preprocess = 6.0
	dust_ring.position = Vector3(7.0, 5.8, -22.0)
	dust_ring.emission_shape = CPUParticles3D.EMISSION_SHAPE_RING
	dust_ring.emission_ring_axis = Vector3(0, 1, 0)
	dust_ring.emission_ring_radius = _orbit
	dust_ring.emission_ring_inner_radius = _orbit - 0.8
	dust_ring.emission_ring_height = 0.2
	dust_ring.gravity = Vector3.ZERO
	dust_ring.scale_amount_min = 0.6
	dust_ring.scale_amount_max = 1.2
	var qm := QuadMesh.new()
	qm.size = Vector2(0.06, 0.06)
	dust_ring.mesh = qm
	var dm := StandardMaterial3D.new()
	dm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dm.albedo_color = Color(0.85, 0.7, 0.55, 0.8)
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	dust_ring.material_override = dm
	dust_ring.emitting = false
	add_child(dust_ring)
	# a comet on a very long orbit
	comet = Mk.group(self, "comet")
	comet_head = Mk.sprite(comet, Tex.radial(Color(0.85, 0.95, 1.0, 1.0), 0.6), 0, 0, 0, 0.06, true, false)
	comet_head.offset = Vector2.ZERO
	comet_trail = CPUParticles3D.new()
	comet_trail.amount = 50
	comet_trail.lifetime = 2.0
	comet_trail.gravity = Vector3.ZERO
	comet_trail.direction = Vector3(1, 0.25, 0)
	comet_trail.spread = 6.0
	comet_trail.initial_velocity_min = 4.0
	comet_trail.initial_velocity_max = 6.0
	comet_trail.scale_amount_min = 0.5
	comet_trail.scale_amount_max = 1.4
	var cq := QuadMesh.new()
	cq.size = Vector2(0.3, 0.3)
	comet_trail.mesh = cq
	var cm := StandardMaterial3D.new()
	cm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cm.albedo_texture = Tex.radial(Color(0.7, 0.9, 1.0, 0.5), 1.0)
	cm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	comet_trail.material_override = cm
	comet.add_child(comet_trail)
	# the singing crystal
	crystal = Mk.group(self, "crystal", 0.84, 0.0, 1.0)
	var cmat := Mk.glass(Color("49d8e8"), 1.5)
	Mk.cy(crystal, 0, 0, 0, 0.16, 0.0, 1.5, cmat, 5, false)
	Mk.cy(crystal, 0.18, 0, -0.05, 0.08, 0.0, 0.8, Mk.glass(Color("8aecf8"), 1.6), 5, false)
	crystal_light = Mk.omni(crystal, 0, 0.8, 0.3, Color(0.5, 0.95, 1.0), 0.7, 5.0, false)
	for i in 5:
		var r := MeshInstance3D.new()
		var t := TorusMesh.new()
		t.inner_radius = 0.98
		t.outer_radius = 1.0
		r.mesh = t
		r.material_override = Mk.glass(Color(0.6, 1.0, 1.0, 0.5), 1.4)
		r.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(r)
		rings.append(r)

func _build_dark() -> void:
	for i in 4:
		var g := Mk.group(self, "hole%d" % i, 1.5 + i * 2.5 + Tex.n2(i, 1, 51), 3.2 + Tex.n2(i, 2, 51) * 3.0, -18.0 - Tex.n2(i, 3, 51) * 10.0)
		Mk.sp(g, 0, 0, 0, 0.6, Mk.flat(Color.BLACK, 1.0), false)
		var ring := MeshInstance3D.new()
		var t := TorusMesh.new()
		t.inner_radius = 0.95
		t.outer_radius = 1.15
		ring.mesh = t
		ring.material_override = Mk.glass(Color(1.0, 0.65, 0.3, 0.8), 1.6)
		ring.rotation_degrees = Vector3(78, 0, 8)
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		g.add_child(ring)
		Mk.omni(g, 0, 0, 1.0, Color(1.0, 0.6, 0.3), 0.6, 12.0, false)
		holes.append(g)
	photon = Mk.sp(self, 0, 0, 0, 0.05, Mk.glass(Color.WHITE, 3.0), false)
	photon_light = Mk.omni(self, 0, 0, 0, Color(1, 1, 1), 0.0, 5.0, false)
	for i in 5:
		var r := MeshInstance3D.new()
		var t := TorusMesh.new()
		t.inner_radius = 0.985
		t.outer_radius = 1.0
		r.mesh = t
		r.material_override = Mk.glass(Color(0.6, 1.0, 1.0, 0.4), 1.3)
		r.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(r)
		rings.append(r)

func _planet_tex() -> ImageTexture:
	var w := 64
	var h := 32
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var n := Tex.tn(x, y, w, h, 4.0, 201) * 0.65 + Tex.tn(x, y, w, h, 8.0, 202) * 0.35
			var c := Color("2a5aa0").lerp(Color("5ab0e0"), Tex.n2(x, y, 5) * 0.2)
			if n > 0.52:
				c = Color("3a8a3a").lerp(Color("8a7a4a"), clampf((n - 0.62) * 4.0, 0.0, 1.0))
			if absi(y - h / 2) > 13:
				c = Color("e8f0f8")
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)

func update(x: Dictionary, _dt: float) -> void:
	var vis: String = x["vis"]
	var run: bool = x["run"]
	var p: float = x["p"]
	var t: float = x["t"]
	var spots: Array = x["spots"]
	# beacons only for what is currently available
	for i in beacons.size():
		var on := false
		for s in spots:
			if absf(float(s) * U - float(beacon_x[i])) < 0.05:
				on = true
		(beacons[i] as Node3D).visible = on
		(beacons[i] as Node3D).position.y = 0.04 * sin(t * 1.5 + i)
	for d in debris:
		var m := d as MeshInstance3D
		var i: int = m.get_meta("i")
		m.position.y = -2.0 - Tex.n2(i, 2, 33) * 2.0 + sin(t * 0.4 + i) * 0.15
		m.rotation_degrees.y += 0.1 + i * 0.02
	if dark:
		_update_dark(x, vis, run, p, t)
	else:
		_update_stars(x, vis, run, p, t)

func _update_stars(x: Dictionary, vis: String, run: bool, p: float, t: float) -> void:
	stars_alpha = 1.0
	flash_amt = 0.0
	var formed := flag(x, "planet_formed")
	var forming := vis == "planet" and run
	# nebula
	nebula.visible = (not formed) or forming
	nebula.scale = Vector3.ONE * (1.0 - (p * 0.6 if forming else 0.0))
	nebula.rotation_degrees.z = t * 0.4
	# the system
	var has_sys := formed or forming or flag(x, "found_nursery")
	var r_star := 1.2
	var star_col := Color("ffe9a0")
	var swallowed := flag(x, "swallowed")
	var old := flag(x, "sun_lived")
	var sw := vis == "swallow" and run
	if forming:
		r_star = 0.4 + p * 0.8
		star_col = Color("ff9a60").lerp(Color("ffe9a0"), p)
	elif vis == "star" and run:
		r_star = 1.2 + p * 0.5
		star_col = Color("ffe9a0").lerp(Color("ffb060"), p)
	elif sw:
		r_star = 1.7 + p * p * 22.0
		star_col = Color("ffb060").lerp(Color("c8342a"), minf(1.0, p * 1.5))
	elif swallowed:
		r_star = 0.12
		star_col = Color("d0e0ff")
	elif old:
		r_star = 2.2
		star_col = Color("e0603a")
	elif not formed:
		r_star = 0.5
		star_col = Color("ff8a50")
	star.visible = has_sys or swallowed
	star.scale = Vector3.ONE * (r_star / 1.2)
	star_mat.albedo_color = Color(star_col.r * 2.2, star_col.g * 2.2, star_col.b * 2.2)
	star_light.light_energy = (1.9 * clampf(r_star / 1.2, 0.3, 2.5)) if (has_sys and not swallowed) else (0.4 if swallowed else 0.0)
	star_light.light_color = star_col
	core_light.light_energy = 0.9
	# the planet
	var show_planet := (formed or forming) and not swallowed
	if sw and r_star > _orbit - 1.0:
		show_planet = false
	planet.visible = show_planet
	var ang := t * 0.5
	var pr := 0.5
	if forming:
		pr = 0.1 + 0.4 * p
	planet.scale = Vector3.ONE * (pr / 0.5)
	planet.position = Vector3(7.0 + cos(ang) * _orbit, 5.8 + sin(ang) * 1.1, -22.0 + sin(ang) * _orbit * 0.9)
	planet.rotation_degrees.y = t * 20.0
	dust_ring.emitting = forming and p < 0.85
	# the comet
	var comet_on := false
	if vis == "comet" and run:
		comet_on = true
		comet.position = Vector3(16.0 - p * 22.0, 6.5 + sin(p * 6.0) * 1.2 - p * 1.5, -12.0)
	elif flag(x, "comet_seen"):
		comet_on = true
		comet.position = Vector3(11.0, 7.2, -16.0)
	comet.visible = comet_on
	comet_trail.emitting = comet_on
	# the crystal
	show_if(crystal, flag(x, "found_crystal"))
	crystal_light.light_energy = 0.7 + 0.3 * sin(t * 2.0)
	_rings_update(vis == "music" and run, Vector3(0.84, 0.9, 1.0), t)
	# whiteout as the sun swallows everything
	if sw and p > 0.86:
		flash_amt = clampf((p - 0.86) / 0.14, 0.0, 1.0)

func _update_dark(x: Dictionary, vis: String, run: bool, p: float, t: float) -> void:
	flash_amt = 0.0
	var alive := 1.0
	if flag(x, "stars_out"):
		alive = 0.0
	if vis == "stars" and run:
		alive = 1.0 - p
	stars_alpha = alive
	var gone := flag(x, "light_gone")
	# the slab fades with the last light
	slab_mat.albedo_color = Color(1, 1, 1).lerp(Color(0.25, 0.25, 0.3), 0.5 if not gone else 0.9)
	core_light.light_energy = 0.0 if gone else 0.35 + 0.3 * alive
	# black holes shrink and vanish
	var hl := 0.0
	if flag(x, "holes_gone"):
		hl = 0.0
	elif vis == "holes" and run:
		hl = 1.0 - p
	elif flag(x, "found_holes"):
		hl = 1.0
	for i in holes.size():
		var h := holes[i] as Node3D
		h.visible = hl > 0.02
		h.scale = Vector3.ONE * maxf(hl, 0.01)
		h.rotation_degrees.y = t * (20.0 + i * 5.0)
	# the last photon
	var ph := vis == "photon" and run
	photon.visible = ph
	if ph:
		var a := (1.0 - p) * (1.0 - p) * (0.6 + 0.4 * sin(t * 18.0))
		photon.position = Vector3(2.0 + p * 4.0 + fposmod(t * 3.0, 6.0) * (1.0 - p), 3.5, -4.0)
		photon_light.position = photon.position
		photon_light.light_energy = clampf(a, 0.0, 1.0) * 2.0
	else:
		photon_light.light_energy = 0.0
	_rings_update(vis == "music" and run, Vector3(x["hx"] * U + 0.3, 1.0, hero_z), t)

func _rings_update(active: bool, at: Vector3, t: float) -> void:
	for i in rings.size():
		var r := rings[i] as MeshInstance3D
		r.visible = active
		if active:
			var ph := fposmod(t * 0.45 + i / float(rings.size()), 1.0)
			r.position = at
			r.scale = Vector3.ONE * (0.2 + ph * (3.0 if not dark else 6.0))
			r.rotation_degrees = Vector3(90, 0, 0)
