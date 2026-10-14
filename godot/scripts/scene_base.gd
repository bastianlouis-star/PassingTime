class_name SceneBase
extends Node3D
# Base for every era's 3D diorama. x-positions in the game data are "units"
# (0..320); one unit is U metres.

const U := 0.03

var hero_z := 1.7
var cam_dist := 9.4
var cam_h := 3.6
var look_y := 1.5
var cam_min := 0.0
var cam_max := 10.0
var width_m := 9.8
var marker_y := 2.1
var sun: DirectionalLight3D
var moon: DirectionalLight3D
var fill: DirectionalLight3D
var sky_mat: ProceduralSkyMaterial
var clouds_root: Node3D
var ridges: Array = []
var env: Environment
var outdoor := false
var stars_alpha := -1.0       # >= 0 forces the star dome (space eras)
var flash_amt := 0.0          # white-out overlay
var hero: Hero3D

func build() -> void:
	pass

func update(_x: Dictionary, _dt: float) -> void:
	pass

# where the hero actually is while doing something sitting down ({} = where he stands)
var cam_off := 0.0     # shifts the framing sideways (positive moves the scene left on screen)

func seat(_x: Dictionary) -> Dictionary:
	return {}

# helpers shared by scenes -----------------------------------------------------

func make_env(bg: Color, amb: Color, amb_e: float) -> void:
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = bg
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = amb
	env.ambient_light_energy = amb_e
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.0
	env.tonemap_white = 6.0

func make_sun(shadow_dist: float = 30.0) -> void:
	sun = DirectionalLight3D.new()
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	sun.directional_shadow_max_distance = shadow_dist
	sun.shadow_bias = 0.03
	sun.shadow_normal_bias = 1.0
	sun.light_specular = 0.0
	add_child(sun)

# points the sun along `dir` (the direction light travels)
func aim_sun(dir: Vector3) -> void:
	sun.basis = Basis.looking_at(dir.normalized(), Vector3.UP)

func flag(x: Dictionary, f: String) -> bool:
	var fl: Dictionary = x["fl"]
	return fl.has(f)

func show_if(n: Node, cond: bool) -> void:
	if n != null:
		n.visible = cond
