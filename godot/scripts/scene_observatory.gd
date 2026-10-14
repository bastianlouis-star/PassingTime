class_name SceneObservatory
extends SceneBase
# Era 4: a stone terrace above a great plain. An empire rises and falls on it, and a
# glacier creeps down the northern ridge.

var city: Array = []          # buildings
var temples: Array = []
var scribe: Node3D
var vols: Array = []
var ruins_prop: Node3D
var rubble: Node3D
var glacier: Node3D
var ice_tongue: MeshInstance3D
var groove: MeshInstance3D
var quill_glow: OmniLight3D
var smoke: CPUParticles3D
var _py := -4.0

func build() -> void:
	outdoor = true
	width_m = 10.0
	hero_z = 1.9
	cam_min = 4.9
	cam_max = 5.2
	marker_y = 2.7
	SkyKit.setup(self)
	var fs := Mk.tex(Tex.flagstone("6e685c"), 1.0)
	var fs_l := Mk.tex(Tex.flagstone("8a8476"), 1.0)
	# terrace
	Mk.bb(self, -6.0, -0.4, -1.0, 16.0, 0.0, 10.0, fs)
	for i in 14:
		Mk.bb(self, -5.0 + i * 1.6, 0.0, -1.0, -4.2 + i * 1.6, 0.95, -0.7, fs_l)
		Mk.bb(self, -5.0 + i * 1.6, 0.95, -1.0, -4.5 + i * 1.6, 1.25, -0.7, fs_l)
	Mk.bb(self, -6.0, 0.0, -1.0, 16.0, 0.9, -0.72, fs)
	# the plain far below
	Kit.ground(self, -40.0, 60.0, -80.0, -1.0, Mk.tex(Tex.grass(), 0.45, Color(1.0, 0.95, 0.7)), _py)
	for i in 10:
		Mk.quad(self, -2.0 + i * 2.6, _py + 0.02, -7.0 - Tex.n2(i, 1, 2) * 40.0, 5.0, 6.0, Mk.flat([Color("8aa850"), Color("c8b060"), Color("6a9a48")][i % 3], 1.0), Vector3(-90, 0, 0))
	Mk.quad(self, 8.0, _py + 0.03, -26.0, 1.6, 40.0, Mk.glass(Color("5aa0c0"), 0.95), Vector3(-90, 0, 0))
	# the empire (grows, then crumbles)
	var wall := Mk.tex(Tex.marble(), 1.4)
	for i in 28:
		var bx := -2.0 + (i % 7) * 2.0 + Tex.n2(i, 1, 21) * 0.5
		var bz := -9.0 - (i / 7) * 2.4 - Tex.n2(i, 2, 21) * 0.6
		var h := 0.7 + Tex.n2(i, 3, 21) * 1.8
		if i % 6 == 3:
			var tg := Mk.group(self, "temple", bx, _py, bz)
			for k in 6:
				Mk.cy(tg, -0.9 + k * 0.36, 0, 0, 0.1, 0.1, 1.5, Mk.tex(Tex.marble(), 2.0), 10)
			Mk.bx(tg, 0, 1.5, 0, 2.2, 0.15, 0.7, wall)
			var pm := PrismMesh.new()
			pm.size = Vector3(2.3, 0.6, 0.75)
			var pi := MeshInstance3D.new()
			pi.mesh = pm
			pi.material_override = Mk.tex(Tex.marble(), 2.0)
			pi.position = Vector3(0, 1.95, 0)
			tg.add_child(pi)
			Mk.bx(tg, 0, 0, 0, 2.4, 0.12, 0.8, wall)
			temples.append(tg)
		else:
			var b := Kit.building(self, bx, bz, 1.2, 1.2, h, Mk.tex(Tex.plaster("d8c8a8"), 1.2), "b05a3a", 0.5)
			b.position.y = _py
			city.append(b)
	# smoke from the city
	smoke = CPUParticles3D.new()
	smoke.amount = 20
	smoke.lifetime = 5.0
	smoke.position = Vector3(3.0, _py + 2.0, -10.0)
	smoke.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	smoke.emission_box_extents = Vector3(6.0, 0.2, 3.0)
	smoke.gravity = Vector3(0.1, 0.4, 0)
	smoke.initial_velocity_min = 0.1
	smoke.initial_velocity_max = 0.3
	smoke.scale_amount_min = 3.0
	smoke.scale_amount_max = 6.0
	var qm := QuadMesh.new()
	qm.size = Vector2(0.3, 0.3)
	smoke.mesh = qm
	var sm := StandardMaterial3D.new()
	sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.albedo_texture = Tex.radial(Color(0.6, 0.6, 0.62, 0.35), 1.0)
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	smoke.material_override = sm
	add_child(smoke)
	# the northern ridge and its glacier
	Kit.ridge(self, -46.0, -3.0, 14.0, 5.0, Color("5a6a7a"), 0.55, true)
	Kit.ridge(self, -70.0, 0.0, 26.0, 11.0, Color("6a82a0"), 0.8, true)
	glacier = Mk.group(self, "glacier")
	ice_tongue = Mk.bb(glacier, 9.0, 0.0, -45.0, 12.0, 0.6, -33.0, Mk.tex(Tex.ice(), 0.9))
	ice_tongue.rotation_degrees = Vector3(-18, 0, 0)
	ice_tongue.position = Vector3(10.5, 5.0, -39.0)
	groove = Mk.bb(glacier, 8.5, 0.0, -44.0, 12.5, 0.5, -34.0, Mk.flat(Color("2a3a4a"), 1.0))
	groove.rotation_degrees = Vector3(-18, 0, 0)
	groove.position = Vector3(10.5, 4.6, -39.0)
	# the scribe's desk
	scribe = Mk.group(self, "scribe")
	var wl := Mk.tex(Tex.wood("8a5a3a"), 3.0)
	var wd := Mk.tex(Tex.wood("5a3a24"), 3.0)
	Mk.bb(scribe, 3.8, 0.78, 0.3, 5.2, 0.84, 1.1, wl)
	for lx in [3.85, 5.1]:
		Mk.bb(scribe, lx, 0, 0.35, lx + 0.07, 0.78, 0.42, wd)
		Mk.bb(scribe, lx, 0, 0.98, lx + 0.07, 0.78, 1.05, wd)
	Mk.bb(scribe, 4.2, 0.0, 1.2, 4.7, 0.45, 1.65, wl)
	for i in 5:
		var v := Mk.bx(scribe, 3.95 + i * 0.12, 0.84, 0.5, 0.1, 0.3, 0.22, Mk.flat([Color("a04050"), Color("3a6aa0"), Color("4a9a5a"), Color("7a4a9a"), Color("d07a4a")][i], 0.6))
		vols.append(v)
	Mk.bx(scribe, 4.9, 0.84, 0.7, 0.3, 0.015, 0.22, Mk.flat(Color("f0e8d0"), 0.8))
	Mk.cy(scribe, 5.0, 0.85, 0.82, 0.006, 0.006, 0.3, Mk.flat(Color("f4f4f4")), 5, false).rotation_degrees = Vector3(0, 0, 25)
	quill_glow = Mk.omni(scribe, 4.6, 1.2, 0.8, Color(1.0, 0.85, 0.5), 0.0, 2.0, false)
	# ruins prop
	ruins_prop = Mk.group(self, "ruins")
	var mb := Mk.tex(Tex.marble(), 2.0)
	for i in 3:
		var h := 2.2 - Tex.n2(i, 1, 90) * 1.2
		Mk.cy(ruins_prop, 5.7 + i * 0.55, 0, 0.6, 0.17, 0.17, h, mb, 12)
		Mk.bb(ruins_prop, 5.7 + i * 0.55 - 0.22, h, 0.38, 5.7 + i * 0.55 + 0.22, h + 0.1, 0.82, mb)
	rubble = Mk.group(ruins_prop, "rubble")
	for i in 10:
		Mk.bx(rubble, 5.4 + Tex.n2(i, 1, 91) * 1.5, 0, 1.0 + Tex.n2(i, 2, 91) * 0.4, 0.14 + Tex.n2(i, 3, 91) * 0.12, 0.1, 0.14, mb)
	# stairs down
	for i in 6:
		Mk.bb(self, 9.6 + i * 0.45, -0.2 - i * 0.2, 0.4, 10.05 + i * 0.45, 0.0 - i * 0.2, 2.4, fs)

func update(x: Dictionary, _dt: float) -> void:
	var vis: String = x["vis"]
	var run: bool = x["run"]
	var p: float = x["p"]
	var hot: String = x["hot"]
	var t: float = x["t"]
	SkyKit.update(self, x, 0.05)
	Kit.retint_ridges(self, x["day"])
	var up := 0.0
	var ruin := 0.0
	if vis == "rise" and run:
		up = p
	elif vis == "fall" and run:
		up = 1.0
		ruin = p
	elif flag(x, "empire_fell"):
		up = 1.0
		ruin = 1.0
	elif flag(x, "empire_rose"):
		up = 1.0
	for i in city.size():
		var b: Node3D = city[i]
		var g := clampf(up * 1.5 - Tex.n2(i, 4, 21) * 0.5, 0.0, 1.0)
		var fall := 1.0 - ruin * (0.45 + 0.5 * Tex.n2(i, 12, 21))
		b.visible = g > 0.02
		b.scale = Vector3(1, maxf(g * fall, 0.02), 1)
		b.rotation_degrees.z = ruin * (Tex.n2(i, 6, 21) - 0.5) * 18.0
	for i in temples.size():
		var tg: Node3D = temples[i]
		var gg := clampf(up * 1.4, 0.0, 1.0)
		tg.visible = gg > 0.02
		tg.scale = Vector3(1, maxf(gg * (1.0 - ruin * 0.8), 0.02), 1)
	smoke.emitting = ruin > 0.4 or (up > 0.7 and ruin < 0.2)
	# glacier carving a valley
	var ice := 0.0
	if flag(x, "glacier_done"):
		ice = 1.0
	elif vis == "glacier" and run:
		ice = p
	ice_tongue.visible = ice > 0.02
	groove.visible = ice > 0.02
	ice_tongue.scale = Vector3(1, 1, 0.3 + ice * 0.8)
	groove.scale = Vector3(0.3 + ice * 0.7, 1, 0.3 + ice * 0.8)
	ice_tongue.position.y = 5.0 - ice * 2.2
	groove.position.y = 4.6 - ice * 2.2
	# the scribe
	show_if(scribe, flag(x, "empire_rose"))
	var vcount := 0
	if flag(x, "wrote_history"):
		vcount = 5
	if vis == "write" and run and hot == "scribe":
		vcount = maxi(vcount, int(p * 5.0))
	for i in vols.size():
		(vols[i] as Node3D).visible = i < vcount
	quill_glow.light_energy = 0.8 if (vis == "write" and run) else 0.0
	show_if(ruins_prop, flag(x, "empire_rose"))
	show_if(rubble, flag(x, "empire_fell"))
