class_name SkyKit
extends RefCounted
# Sky / sun / moon maths and the shared outdoor setup used by every open-air era.

const SKY := Color("41a6f6")
const PURPLE := Color("5d275d")
const ORANGE := Color("ef7d57")

static func sun_h(day: float) -> float:
	return -cos(day * TAU)

static func night_amt(day: float) -> float:
	return clampf(0.5 - sun_h(day) * 1.6, 0.0, 1.0)

static func sky_top(day: float) -> Color:
	var s := sun_h(day)
	var col := Color("10122a").lerp(SKY, clampf(s * 2.0 + 0.45, 0.0, 1.0))
	return col.lerp(PURPLE, clampf(1.0 - absf(s) * 4.0, 0.0, 1.0) * 0.55)

static func sky_bot(day: float) -> Color:
	var s := sun_h(day)
	var col := Color("1d2147").lerp(Color("a6dcf2"), clampf(s * 2.0 + 0.4, 0.0, 1.0))
	return col.lerp(ORANGE, clampf(1.0 - absf(s) * 3.5, 0.0, 1.0) * 0.8)

# unit vector pointing from the world towards the sun (or moon, phase = 0.5)
static func body_pos(day: float, phase: float = 0.0) -> Vector3:
	var d := fposmod(day + phase, 1.0)
	var e := sun_h(d) * deg_to_rad(66.0)
	var az := (d - 0.5) * 2.4
	return Vector3(sin(az) * cos(e), sin(e), -cos(az) * cos(e) * 0.8 - 0.25).normalized()

# ---------------------------------------------------------------- setup
# Gives a scene a procedural sky, a sun, a moon, a camera-side fill light and a star dome.
static func setup(s: SceneBase) -> void:
	var sky := Sky.new()
	var psm := ProceduralSkyMaterial.new()
	psm.sun_angle_max = 28.0
	psm.sun_curve = 0.12
	sky.sky_material = psm
	sky.radiance_size = Sky.RADIANCE_SIZE_64
	s.env = Environment.new()
	s.env.background_mode = Environment.BG_SKY
	s.env.sky = sky
	s.env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	s.env.ambient_light_energy = 0.55
	s.env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	s.env.tonemap_white = 6.0
	s.env.tonemap_exposure = 0.7
	s.cam_dist = 13.0
	s.cam_h = 5.2
	s.look_y = 1.3
	s.env.fog_enabled = true
	s.env.fog_light_color = Color("a6dcf2")
	s.env.fog_density = 0.0022
	s.env.fog_sky_affect = 0.0
	s.make_sun(60.0)
	s.moon = DirectionalLight3D.new()
	s.moon.shadow_enabled = false
	s.moon.light_specular = 0.0
	s.moon.light_color = Color(0.55, 0.68, 1.0)
	s.add_child(s.moon)
	s.fill = DirectionalLight3D.new()
	s.fill.shadow_enabled = false
	s.fill.light_specular = 0.0
	s.fill.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
	s.add_child(s.fill)
	s.fill.basis = Basis.looking_at(Vector3(0.25, -0.5, -1.0).normalized(), Vector3.UP)
	s.sky_mat = psm
	# clouds drifting far away
	s.clouds_root = Mk.group(s, "clouds")
	for i in 7:
		var c := Mk.sprite(s.clouds_root, Tex.cloud(), -30.0 + i * 16.0, 22.0 + Tex.n2(i, 1, 9) * 14.0, -70.0 - Tex.n2(i, 2, 9) * 40.0, 0.5 + Tex.n2(i, 3, 9) * 0.4, true, false)
		c.offset = Vector2(0, 0)
		c.modulate = Color(1, 1, 1, 0.92)

static func update(s: SceneBase, x: Dictionary, ambient_boost: float = 0.0) -> void:
	var day: float = x["day"]
	var t: float = x["t"]
	var sh := sun_h(day)
	var night := night_amt(day)
	var top := sky_top(day)
	var bot := sky_bot(day)
	var psm: ProceduralSkyMaterial = s.sky_mat
	psm.sky_top_color = top
	psm.sky_horizon_color = bot
	psm.ground_horizon_color = bot.darkened(0.25)
	psm.ground_bottom_color = Color(0.04, 0.06, 0.09).lerp(Color(0.12, 0.2, 0.14), 1.0 - night)
	s.env.fog_light_color = bot
	s.env.fog_density = lerpf(0.002, 0.004, night)
	# sun
	var sp := body_pos(day)
	s.sun.basis = Basis.looking_at(-sp, Vector3.UP)
	s.sun.light_energy = lerpf(0.0, 1.7, clampf(sh * 1.7, 0.0, 1.0))
	s.sun.light_color = Color(1.0, 0.7, 0.42).lerp(Color(1.0, 0.96, 0.88), clampf(sh * 1.6, 0.0, 1.0))
	s.sun.visible = sh > -0.05
	# moon
	var mp := body_pos(day, 0.5)
	s.moon.basis = Basis.looking_at(-mp, Vector3.UP)
	s.moon.light_energy = 0.55 * clampf(-sh * 1.8, 0.0, 1.0)
	s.moon.visible = sh < 0.05
	s.fill.light_energy = lerpf(0.4, 0.1, night)
	s.fill.light_color = Color(1.0, 0.95, 0.9).lerp(Color(0.5, 0.6, 1.0), night)
	s.env.ambient_light_energy = lerpf(0.55, 0.4, night) + ambient_boost
	# clouds
	if s.clouds_root != null:
		var lit := clampf(sh * 1.4 + 0.45, 0.1, 1.0)
		var i := 0
		for c in s.clouds_root.get_children():
			var sp3 := c as Sprite3D
			sp3.position.x = fposmod(sp3.position.x + 30.0 + 0.8 * 0.016 * (1.0 + i * 0.2), 130.0) - 30.0
			sp3.modulate = Color(0.45 + 0.55 * lit, 0.5 + 0.5 * lit, 0.62 + 0.38 * lit, 0.92)
			i += 1
