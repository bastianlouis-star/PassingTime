class_name Stage3D
extends Node3D
# Owns the camera, the hero billboard and the current era's diorama.

const U := 0.03

var cam: Camera3D
var env_node: WorldEnvironment
var hero: Hero3D
var scene: SceneBase
var cam_x := 0.0
var dome: MeshInstance3D
var dome_mat: StandardMaterial3D
var era := -1

func _ready() -> void:
	cam = Camera3D.new()
	cam.fov = 30.0
	cam.near = 0.2
	cam.far = 200.0
	cam.current = true
	add_child(cam)
	env_node = WorldEnvironment.new()
	add_child(env_node)
	hero = Hero3D.new()
	add_child(hero)
	var sm := SphereMesh.new()
	sm.radius = 150.0
	sm.height = 300.0
	sm.radial_segments = 32
	sm.rings = 16
	dome = MeshInstance3D.new()
	dome.mesh = sm
	dome_mat = StandardMaterial3D.new()
	dome_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dome_mat.albedo_texture = Tex.stars_dome()
	dome_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	dome_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dome_mat.cull_mode = BaseMaterial3D.CULL_FRONT
	dome_mat.albedo_color = Color(1, 1, 1, 0)
	dome.material_override = dome_mat
	dome.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	dome.visible = false
	add_child(dome)

func has_era(i: int) -> bool:
	return true

func set_era(i: int, hero_tex: Dictionary) -> bool:
	if scene != null:
		scene.queue_free()
		scene = null
	era = i
	hero.set_textures(hero_tex)
	match i:
		0: scene = SceneRoom.new()
		1: scene = SceneHouse.new()
		2: scene = SceneRoad.new()
		3: scene = SceneSummit.new()
		4: scene = SceneObservatory.new()
		5: scene = ScenePlateau.new()
		6: scene = SceneSpace.new()
		7:
			var sd := SceneSpace.new()
			sd.dark = true
			scene = sd
		8: scene = SceneNothing.new()
		_: scene = null
	if scene == null:
		return false
	scene.hero = hero
	add_child(scene)
	scene.build()
	env_node.environment = scene.env
	hero.position.z = scene.hero_z
	cam_x = clampf(hero.position.x, scene.cam_min, scene.cam_max)
	return true

func active() -> bool:
	return scene != null

func world_pos(x_units: float, y: float = 0.0) -> Vector3:
	return Vector3(x_units * U, y, scene.hero_z if scene != null else 1.7)

# logical (640x360) screen position of a point in the world
func project(x_units: float, y: float) -> Vector2:
	if scene == null:
		return Vector2(320, 180)
	var p := cam.unproject_position(world_pos(x_units, y))
	var vs := get_viewport().get_visible_rect().size
	return Vector2(p.x * 640.0 / vs.x, p.y * 360.0 / vs.y)

func update(x: Dictionary, dt: float) -> void:
	if scene == null:
		return
	var hx: float = x["hx"]
	var st := scene.seat(x)
	var face: int = x["face"]
	if st.is_empty():
		hero.position = Vector3(hx * U, 0.0, scene.hero_z)
	else:
		hero.position = st["pos"]
		face = st["face"]
	hero.apply(x["pose"], face, x["t"], x["float"])
	var target := clampf(hx * U, scene.cam_min, scene.cam_max)
	cam_x = lerpf(cam_x, target, clampf(dt * 3.0, 0.0, 1.0))
	var cpos := Vector3(cam_x + scene.cam_off, scene.cam_h, scene.hero_z + scene.cam_dist)
	cam.position = cpos
	cam.look_at(Vector3(cam_x + scene.cam_off, scene.look_y, scene.hero_z), Vector3.UP)
	scene.update(x, dt)
	dome.position = cam.position
	if scene.stars_alpha >= 0.0:
		dome.visible = scene.stars_alpha > 0.01
		dome_mat.albedo_color.a = scene.stars_alpha
	else:
		dome.visible = scene.outdoor
		dome_mat.albedo_color.a = SkyKit.night_amt(x["day"]) if scene.outdoor else 0.0
