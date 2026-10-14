class_name ScenePlateau
extends SceneBase
# Era 5: a rock plateau over a sea. Deep time passes: life crawls out, continents drift,
# ice ages come and go, a volcano builds an island.

var ground_mat: StandardMaterial3D
var water_mat: StandardMaterial3D
var continents: Array = []
var stages: Array = []
var fossils: Node3D
var layers: Node3D
var volcano: Node3D
var lava_mat: StandardMaterial3D
var lava_glow: OmniLight3D
var ash: CPUParticles3D
var sparks: CPUParticles3D
var island: Node3D
var spikes: Node3D
var snow: CPUParticles3D
var fire_light: OmniLight3D
var _sea := -4.0

func build() -> void:
	outdoor = true
	width_m = 10.0
	hero_z = 1.9
	cam_min = 4.9
	cam_max = 5.2
	marker_y = 2.7
	SkyKit.setup(self)
	ground_mat = Mk.tex(Tex.flagstone("8a6a50"), 1.0)
	Mk.bb(self, -8.0, -0.6, -2.0, 16.0, 0.0, 10.0, ground_mat)
	Mk.bb(self, -8.0, _sea, -2.1, 16.0, 0.0, -2.0, Mk.tex(Tex.strata(), 0.8))
	Kit.tufts(self, -4.0, 14.0, -1.0, 6.0, 30, 31, "6a7a3a")
	# the sea and its drifting continents
	water_mat = Mk.glass(Color("2a6a9a"), 1.0)
	Mk.quad(self, 4.0, _sea + 0.02, -35.0, 120.0, 70.0, water_mat, Vector3(-90, 0, 0))
	for i in 4:
		var land := Mk.sp(self, 0.0, _sea + 0.1, -22.0 - i * 3.0, 5.5 - i * 0.5, Mk.flat([Color("4a8a3a"), Color("8a7a4a"), Color("5a8a40"), Color("6a8a3a")][i], 1.0), false, 0.12)
		land.set_meta("i", i)
		continents.append(land)
	# life on a low shelf by the water
	var shelf := Mk.group(self, "shelf")
	Mk.bb(shelf, -2.0, _sea, -8.0, 14.0, -3.0, -3.0, Mk.tex(Tex.grass(), 0.9, Color(0.9, 1.0, 0.8)))
	_creatures()
	# fossil wall and cliff face
	fossils = Mk.group(self, "fossils")
	Mk.bb(fossils, 1.7, 0, -0.1, 3.9, 2.1, 0.6, Mk.tex(Tex.strata(), 0.9))
	for i in 3:
		var bq := Mk.quad(fossils, 2.3 + i * 0.5, 1.0 + (i % 2) * 0.4, 0.61, 0.6, 0.3, _bone_mat())
		bq.rotation_degrees.z = (i - 1) * 12.0
	Mk.bb(self, 1.7, 0, -0.1, 3.9, 2.1, 0.6, Mk.tex(Tex.strata(), 0.9))
	var cliff := Mk.bb(self, 4.2, 0, -0.1, 6.6, 3.0, 0.7, Mk.tex(Tex.strata(), 0.9))
	layers = Mk.group(self, "layers")
	for k in 4:
		Mk.bb(layers, 4.3, 0.4 + k * 0.6, 0.7, 6.5, 0.44 + k * 0.6, 0.72, Mk.flat(Color("ffcd75"), 0.5, 0.6))
	cliff.name = "cliff"
	_volcano()
	spikes = Mk.group(self, "spikes")
	var ice := Mk.tex(Tex.ice(), 1.2)
	for k in 6:
		Mk.cy(spikes, 7.0 + k * 0.5, 0, -3.0 + Tex.n2(k, 1, 5), 0.4, 0.0, 2.0 + Tex.n2(k, 2, 5) * 1.6, ice, 6)
	snow = CPUParticles3D.new()
	snow.amount = 120
	snow.lifetime = 5.0
	snow.preprocess = 5.0
	snow.position = Vector3(4.0, 7.0, 1.0)
	snow.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	snow.emission_box_extents = Vector3(9.0, 0.5, 5.0)
	snow.gravity = Vector3(0.3, -1.1, 0)
	snow.scale_amount_min = 0.5
	snow.scale_amount_max = 1.0
	var qm := QuadMesh.new()
	qm.size = Vector2(0.05, 0.05)
	snow.mesh = qm
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.albedo_color = Color(1, 1, 1, 0.9)
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	snow.material_override = sm
	snow.emitting = false
	add_child(snow)
	island = Mk.group(self, "island", 9.5, 0.0, -16.0)
	Mk.sp(island, 0, _sea, 0, 1.6, Mk.tex(Tex.grass(), 1.0), true, 0.5)
	Mk.sp(island, 0, _sea + 0.2, 0, 1.0, Mk.tex(Tex.flagstone("6a5a4a"), 1.2), true, 0.7)
	Kit.ridge(self, -52.0, -4.0, 14.0, 12.0, Color("6a5a7a"), 0.7)
	Kit.ridge(self, -72.0, -4.0, 24.0, 5.0, Color("8a7a9a"), 0.85, true)
	fire_light = Mk.omni(self, 9.0, -1.8, -4.5, Color(1.0, 0.6, 0.25), 0.0, 3.5, false)

func _bone_mat() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = Tex.bone()
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	return m

func _volcano() -> void:
	volcano = Mk.group(self, "volcano", 7.2, _sea, -9.0)
	Mk.cy(volcano, 0, 0, 0, 3.6, 0.7, 5.2, Mk.tex(Tex.rockface("3a2a2e"), 1.2), 16)
	lava_mat = StandardMaterial3D.new()
	lava_mat.albedo_texture = Tex.lava()
	lava_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	lava_mat.emission_enabled = true
	lava_mat.emission_texture = Tex.lava()
	lava_mat.emission_energy_multiplier = 0.5
	Mk.cy(volcano, 0, 5.15, 0, 0.7, 0.7, 0.08, lava_mat, 14, false)
	for k in 3:
		var st := Mk.bx(volcano, (k - 1) * 0.35, 2.0, 0.55 + k * 0.1, 0.18, 3.2, 0.06, lava_mat, false)
		st.rotation_degrees.z = (k - 1) * 14.0
	lava_glow = Mk.omni(volcano, 0, 5.6, 0.5, Color(1.0, 0.45, 0.15), 0.0, 9.0, false)
	ash = CPUParticles3D.new()
	ash.amount = 24
	ash.lifetime = 4.0
	ash.position = Vector3(0, 5.2, 0)
	ash.gravity = Vector3(0.2, 0.5, 0)
	ash.direction = Vector3(0, 1, 0)
	ash.spread = 25.0
	ash.initial_velocity_min = 0.6
	ash.initial_velocity_max = 1.4
	ash.scale_amount_min = 4.0
	ash.scale_amount_max = 9.0
	var qm := QuadMesh.new()
	qm.size = Vector2(0.4, 0.4)
	ash.mesh = qm
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.albedo_texture = Tex.radial(Color(0.22, 0.2, 0.22, 0.6), 1.0)
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	ash.material_override = sm
	volcano.add_child(ash)
	sparks = CPUParticles3D.new()
	sparks.amount = 30
	sparks.lifetime = 2.2
	sparks.position = Vector3(0, 5.2, 0)
	sparks.gravity = Vector3(0, -3.5, 0)
	sparks.direction = Vector3(0, 1, 0)
	sparks.spread = 40.0
	sparks.initial_velocity_min = 2.0
	sparks.initial_velocity_max = 4.5
	sparks.scale_amount_min = 0.5
	sparks.scale_amount_max = 1.0
	var qm2 := QuadMesh.new()
	qm2.size = Vector2(0.09, 0.09)
	sparks.mesh = qm2
	var sm2 := StandardMaterial3D.new()
	sm2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm2.albedo_color = Color(1.0, 0.6, 0.2)
	sm2.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	sparks.material_override = sm2
	sparks.emitting = false
	volcano.add_child(sparks)

func _creatures() -> void:
	for s in 5:
		stages.append(Mk.group(self, "stage%d" % s))
	# 0: single cells
	var cell := Mk.glass(Color("73eff7"), 1.0)
	for i in 8:
		Mk.sp(stages[0], 0.5 + i * 1.2, _sea + 0.3, -5.0 - (i % 3), 0.12, cell, false)
	# 1: fish
	var fish := Mk.flat(Color("3b6ac0"), 0.5)
	for i in 4:
		var f := Mk.group(stages[1], "fish%d" % i, 1.0 + i * 2.6, _sea + 0.4, -4.6 - (i % 2) * 1.5)
		Mk.sp(f, 0, 0, 0, 0.3, fish, true, 0.45)
		Mk.bx(f, -0.38, -0.12, 0, 0.1, 0.26, 0.04, fish, false)
	# 2: lizard
	var lz := Mk.flat(Color("4a8a40"), 0.6)
	var l := Mk.group(stages[2], "lizard", 5.0, -3.0, -5.0)
	Mk.bx(l, 0, 0.1, 0, 0.9, 0.18, 0.28, lz)
	Mk.bx(l, 0.55, 0.14, 0, 0.26, 0.14, 0.2, lz)
	Mk.bx(l, -0.6, 0.12, 0, 0.5, 0.06, 0.08, lz)
	for lx in [-0.25, 0.3]:
		Mk.bx(l, lx, 0, 0.18, 0.06, 0.12, 0.05, lz)
		Mk.bx(l, lx, 0, -0.18, 0.06, 0.12, 0.05, lz)
	# 3: furred quadruped
	var fr := Mk.flat(Color("8a5a3a"), 0.8)
	var q := Mk.group(stages[3], "beast", 6.0, -3.0, -5.0)
	Mk.bx(q, 0, 0.45, 0, 1.1, 0.5, 0.45, fr)
	Mk.bx(q, 0.65, 0.65, 0, 0.4, 0.34, 0.34, fr)
	Mk.bx(q, 0.85, 0.95, 0.08, 0.08, 0.14, 0.06, fr, false)
	Mk.bx(q, 0.85, 0.95, -0.08, 0.08, 0.14, 0.06, fr, false)
	for lx in [-0.4, 0.4]:
		Mk.bx(q, lx, 0, 0.16, 0.1, 0.45, 0.1, fr)
		Mk.bx(q, lx, 0, -0.16, 0.1, 0.45, 0.1, fr)
	# 4: people around a fire
	for k in 3:
		Mk.sprite(stages[4], Tex.figure([Color("8a6a4a"), Color("a07a5a"), Color("7a5a3a")][k], Color("2a1a10")), 8.4 + k * 0.7, -3.0, -4.6 - (k % 2) * 0.5, 0.09, true, true)
	Mk.sp(stages[4], 9.0, -2.85, -4.3, 0.12, Mk.glass(Color("ff8030"), 1.6), false)

func update(x: Dictionary, _dt: float) -> void:
	var vis: String = x["vis"]
	var run: bool = x["run"]
	var p: float = x["p"]
	var t: float = x["t"]
	var x2 := x.duplicate()
	x2["day"] = 0.27                          # an endless red dawn
	SkyKit.update(self, x2, 0.1)
	Kit.retint_ridges(self, 0.27)
	# ice ages
	var cold := 0.0
	if vis == "ice" and run:
		cold = (1.0 - cos(p * TAU * 3.0)) / 2.0
	elif flag(x, "iced"):
		cold = 0.1
	ground_mat.albedo_color = Color(1, 1, 1).lerp(Color(1.3, 1.35, 1.45), cold)
	water_mat.albedo_color = Color("2a6a9a").lerp(Color("c8dcec"), cold)
	snow.emitting = cold > 0.35
	spikes.visible = flag(x, "drifted")
	# drifting continents
	var dr := 0.0
	if vis == "drift" and run:
		dr = p
	elif flag(x, "drifted"):
		dr = 1.0
	for c in continents:
		var cn := c as MeshInstance3D
		var i: int = cn.get_meta("i")
		cn.position.x = 4.0 + (i - 1.5) * 6.0 + (i - 1.5) * dr * 9.0
	# life
	var stage := -1
	if vis == "evolve" and run:
		stage = mini(4, int(p * 5.0))
	elif flag(x, "evolved"):
		stage = 4
	for i in stages.size():
		(stages[i] as Node3D).visible = i == stage
	fire_light.light_energy = (0.8 + 0.2 * sin(t * 12.0)) if stage == 4 else 0.0
	# the volcano
	var show_v := flag(x, "evolved")
	volcano.visible = show_v
	var active := vis == "volcano" and run
	lava_glow.light_energy = 2.0 if active else (0.5 if flag(x, "island_born") else 0.0)
	lava_mat.emission_energy_multiplier = 1.6 if active else 0.5
	sparks.emitting = active
	ash.emitting = show_v
	show_if(island, flag(x, "island_born") or (active and p > 0.4))
	show_if(fossils, true)
	for b in fossils.get_children():
		if b is MeshInstance3D and (b as MeshInstance3D).mesh is QuadMesh:
			b.visible = flag(x, "found_fossil")
	show_if(layers, flag(x, "seen_layers"))
