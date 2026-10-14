extends SceneTree
# Paints the hero's frames for a few eras into docs/hero_sheet.png for a close look.
#   godot --headless --path godot --script tools/hero_sheet.gd
func _initialize() -> void:
	var eras := [0, 3, 8]
	var poses := ["idle", "walk_a", "walk_c", "sit", "read"]
	var sheet := Image.create(Sprites.W * poses.size(), Sprites.H * eras.size(), false, Image.FORMAT_RGBA8)
	sheet.fill(Color("5a6a8a"))
	for r in eras.size():
		for c in poses.size():
			var tx: ImageTexture = Sprites.make(eras[r], poses[c])
			sheet.blend_rect(tx.get_image(), Rect2i(0, 0, Sprites.W, Sprites.H), Vector2i(c * Sprites.W, r * Sprites.H))
	sheet.resize(sheet.get_width() * 3, sheet.get_height() * 3, Image.INTERPOLATE_NEAREST)
	var path := ProjectSettings.globalize_path("res://").path_join("../docs/hero_sheet.png")
	sheet.save_png(path)
	print("wrote ", path)
	quit(0)
