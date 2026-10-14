class_name Mk
extends RefCounted
# Tiny helpers for building the 3D dioramas out of primitives.
# Convention: bx/cy/... take the BOTTOM-CENTRE of the shape as their position.

static var _mats := {}

static func flat(col: Color, rough: float = 0.85, emis: float = 0.0) -> StandardMaterial3D:
	var k := "f%s_%s_%s" % [col.to_html(), rough, emis]
	if _mats.has(k):
		return _mats[k]
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = rough
	m.metallic_specular = 0.25
	if emis > 0.0:
		m.emission_enabled = true
		m.emission = col
		m.emission_energy_multiplier = emis
	_mats[k] = m
	return m

# a texture that tiles in world space: one repeat per (1/scale) metres
static func tex(t: Texture2D, scale: float = 1.0, tint: Color = Color.WHITE, rough: float = 0.9) -> StandardMaterial3D:
	var k := "t%s_%s_%s_%s" % [t.get_instance_id(), scale, tint.to_html(), rough]
	if _mats.has(k):
		return _mats[k]
	var m := StandardMaterial3D.new()
	m.albedo_texture = t
	m.albedo_color = tint
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3(scale, scale, scale)
	m.roughness = rough
	m.metallic_specular = 0.2
	_mats[k] = m
	return m

# a texture mapped once over a mesh's own UVs (rugs, pictures, screens)
static func uvtex(t: Texture2D, tint: Color = Color.WHITE, emis: float = 0.0, rough: float = 0.9) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = t
	m.albedo_color = tint
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	m.roughness = rough
	if emis > 0.0:
		m.emission_enabled = true
		m.emission_texture = t
		m.emission_energy_multiplier = emis
	return m

static func glass(col: Color, emis: float = 1.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if emis > 0.0:
		m.albedo_color = Color(col.r * emis, col.g * emis, col.b * emis, col.a)
	if col.a < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

static func _inst(parent: Node, mesh: Mesh, mat: Material, pos: Vector3, shadow: bool) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

static func bx(parent: Node, x: float, y: float, z: float, w: float, h: float, d: float, mat: Material, shadow: bool = true) -> MeshInstance3D:
	var m := BoxMesh.new()
	m.size = Vector3(w, h, d)
	return _inst(parent, m, mat, Vector3(x, y + h / 2.0, z), shadow)

# box given by its min/max corners
static func bb(parent: Node, x0: float, y0: float, z0: float, x1: float, y1: float, z1: float, mat: Material, shadow: bool = true) -> MeshInstance3D:
	return bx(parent, (x0 + x1) / 2.0, y0, (z0 + z1) / 2.0, x1 - x0, y1 - y0, z1 - z0, mat, shadow)

static func cy(parent: Node, x: float, y: float, z: float, r_bottom: float, r_top: float, h: float, mat: Material, sides: int = 14, shadow: bool = true) -> MeshInstance3D:
	var m := CylinderMesh.new()
	m.bottom_radius = r_bottom
	m.top_radius = r_top
	m.height = h
	m.radial_segments = sides
	m.rings = 1
	return _inst(parent, m, mat, Vector3(x, y + h / 2.0, z), shadow)

static func sp(parent: Node, x: float, y: float, z: float, r: float, mat: Material, shadow: bool = true, squash: float = 1.0) -> MeshInstance3D:
	var m := SphereMesh.new()
	m.radius = r
	m.height = r * 2.0 * squash
	m.radial_segments = 16
	m.rings = 8
	return _inst(parent, m, mat, Vector3(x, y, z), shadow)

static func quad(parent: Node, x: float, y: float, z: float, w: float, h: float, mat: Material, rot: Vector3 = Vector3.ZERO, shadow: bool = false) -> MeshInstance3D:
	var m := QuadMesh.new()
	m.size = Vector2(w, h)
	var mi := _inst(parent, m, mat, Vector3(x, y, z), shadow)
	mi.rotation_degrees = rot
	return mi

static func omni(parent: Node, x: float, y: float, z: float, col: Color, energy: float, rng: float, shadow: bool = true) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = Vector3(x, y, z)
	l.light_color = col
	l.light_energy = energy
	l.omni_range = rng
	l.omni_attenuation = 1.4
	l.light_specular = 0.0
	l.shadow_enabled = shadow
	l.shadow_bias = 0.04
	parent.add_child(l)
	return l

static func spot(parent: Node, x: float, y: float, z: float, target: Vector3, col: Color, energy: float, rng: float, angle: float, shadow: bool = true) -> SpotLight3D:
	var l := SpotLight3D.new()
	l.position = Vector3(x, y, z)
	l.light_color = col
	l.light_energy = energy
	l.spot_range = rng
	l.spot_angle = angle
	l.spot_attenuation = 0.6
	l.light_specular = 0.0
	l.shadow_enabled = shadow
	parent.add_child(l)
	l.look_at_from_position(l.position, target, Vector3.UP)
	return l

static func sprite(parent: Node, t: Texture2D, x: float, y: float, z: float, pixel_size: float, billboard: bool = true, shaded: bool = true) -> Sprite3D:
	var s := Sprite3D.new()
	s.texture = t
	s.pixel_size = pixel_size
	s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	s.shaded = shaded
	s.double_sided = true
	s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	s.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_OFF
	if billboard:
		s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	s.centered = true
	s.offset = Vector2(0, t.get_height() / 2.0)      # feet at the node origin
	s.position = Vector3(x, y, z)
	parent.add_child(s)
	return s

static func group(parent: Node, nm: String, x: float = 0.0, y: float = 0.0, z: float = 0.0) -> Node3D:
	var n := Node3D.new()
	n.name = nm
	n.position = Vector3(x, y, z)
	parent.add_child(n)
	return n
