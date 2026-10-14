class_name Hero3D
extends Node3D
# The hero: a painted high-resolution sprite standing in the 3D world, lit by the scene's
# lights, with a soft blob shadow.

const PIXEL := 1.78 / 157.0

var spr: Sprite3D
var blob: MeshInstance3D
var tex := {}
var _base_img: Image
var _base_tex: Texture2D

func _ready() -> void:
	spr = Sprite3D.new()
	spr.pixel_size = PIXEL
	spr.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	spr.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	spr.shaded = true
	spr.double_sided = true
	spr.alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
	spr.centered = true
	spr.offset = Vector2(0, 77)
	add_child(spr)
	var q := QuadMesh.new()
	q.size = Vector2(0.95, 0.5)
	blob = MeshInstance3D.new()
	blob.mesh = q
	var m := StandardMaterial3D.new()
	m.albedo_texture = Tex.radial(Color(0, 0, 0, 0.55), 1.4)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	blob.material_override = m
	blob.rotation_degrees = Vector3(-90, 0, 0)
	blob.position = Vector3(0, 0.012, 0)
	blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(blob)

func set_textures(t: Dictionary) -> void:
	tex = t

func apply(pose: String, face: int, t: float, floating: bool) -> void:
	if tex.is_empty() or spr == null:
		return
	var tx: Texture2D
	var yoff := 0.0
	match pose:
		"walk":
			var wf: Array = tex["walk"]
			var wi := int(t * 9.0) % 4
			tx = wf[wi]
			yoff = 0.02 if wi % 2 == 1 else 0.0
		"sit":
			tx = tex["sit"]
		"read":
			tx = tex["read"]
		"bob":
			tx = tex["idle"]
			yoff = 0.015 if int(t * 3.0) % 2 == 0 else 0.0
		_:
			tx = tex["idle"]
	spr.texture = tx
	spr.flip_h = face < 0
	spr.position.y = yoff + (0.06 * sin(t * 1.4) if floating else 0.0)
	blob.visible = not floating

# disappearance in little square blocks of him (d: 0..1)
func dissolve(d: float) -> void:
	if tex.is_empty() or spr == null or d <= 0.0:
		return
	var src: Texture2D = tex["idle"]
	if _base_img == null or _base_tex != src:
		_base_img = src.get_image()
		_base_tex = src
	var img := _base_img.duplicate() as Image
	var bs := 4
	for by in range(img.get_height() / bs):
		for bx in range(img.get_width() / bs):
			var k := Tex.n2(bx, by, 77)
			if d > k and (d - k) * 3.0 > 0.35:
				img.fill_rect(Rect2i(bx * bs, by * bs, bs, bs), Color(0, 0, 0, 0))
	spr.texture = ImageTexture.create_from_image(img)
	spr.position.y += d * 0.1
