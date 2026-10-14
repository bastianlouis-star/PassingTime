class_name SceneNothing
extends SceneBase
# Era 8: nothing but him. He lets go, pixel by pixel; one last atom drifts and stops.

var atom: MeshInstance3D
var atom_light: OmniLight3D
var motes: CPUParticles3D
var aura: OmniLight3D

func build() -> void:
	outdoor = false
	width_m = 10.0
	hero_z = 1.4
	cam_dist = 9.0
	cam_h = 1.9
	look_y = 1.4
	cam_min = 4.8
	cam_max = 4.8
	marker_y = 2.4
	make_env(Color("000000"), Color(0.15, 0.17, 0.3), 0.35)
	make_sun(1.0)
	sun.light_energy = 0.0
	sun.shadow_enabled = false
	aura = Mk.omni(self, 4.8, 1.6, 2.6, Color(0.6, 0.7, 1.0), 0.5, 8.0, false)
	atom = Mk.sp(self, 4.8, 1.4, 1.4, 0.03, Mk.glass(Color.WHITE, 3.0), false)
	atom.visible = false
	atom_light = Mk.omni(self, 4.8, 1.4, 1.4, Color(1, 1, 1), 0.0, 3.0, false)
	motes = CPUParticles3D.new()
	motes.amount = 90
	motes.lifetime = 5.0
	motes.position = Vector3(4.8, 1.0, 1.4)
	motes.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	motes.emission_box_extents = Vector3(0.25, 0.8, 0.1)
	motes.gravity = Vector3(0, 0.08, 0)
	motes.initial_velocity_min = 0.05
	motes.initial_velocity_max = 0.3
	motes.spread = 180.0
	motes.scale_amount_min = 0.6
	motes.scale_amount_max = 1.4
	var qm := QuadMesh.new()
	qm.size = Vector2(0.03, 0.03)
	motes.mesh = qm
	var mm := StandardMaterial3D.new()
	mm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mm.albedo_color = Color(0.9, 0.95, 1.0, 0.8)
	mm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	motes.material_override = mm
	motes.emitting = false
	add_child(motes)

func update(x: Dictionary, _dt: float) -> void:
	var vis: String = x["vis"]
	var run: bool = x["run"]
	var p: float = x["p"]
	var t: float = x["t"]
	stars_alpha = 0.0
	var ended: bool = x["ended"]
	var d := 0.0
	if ended:
		d = 1.0
	elif vis == "dissolve" and run:
		d = p
	if hero != null:
		hero.dissolve(d)
		hero.visible = d < 1.0
	motes.emitting = d > 0.02 and d < 1.0
	aura.light_energy = 0.5 * (1.0 - d)
	# the last atom drifts, slows, stops
	atom.visible = ended
	if ended:
		var et: float = x["ended_t"]
		var k := 1.0 - exp(-et * 0.42)
		atom.position = Vector3(4.8 + 0.9 * k, 1.4 + 0.5 * k, 1.4)
		var moving := et < 10.0
		var tw := 0.5 + 0.5 * sin(t * (6.0 if moving else 1.2))
		atom_light.position = atom.position
		atom_light.light_energy = 0.5 + 0.7 * tw
	else:
		atom_light.light_energy = 0.0
