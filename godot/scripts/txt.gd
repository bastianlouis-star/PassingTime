class_name Txt
extends RefCounted
# Crisp vector text for the HUD (the world itself is pixel art).

static var _sans: SystemFont
static var _serif: SystemFont

static func sans() -> Font:
	if _sans == null:
		_sans = SystemFont.new()
		_sans.font_names = PackedStringArray(["Segoe UI", "Tahoma", "Verdana", "Arial"])
		_sans.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
		_sans.hinting = TextServer.HINTING_LIGHT
	return _sans

static func serif() -> Font:
	if _serif == null:
		_serif = SystemFont.new()
		_serif.font_names = PackedStringArray(["Georgia", "Cambria", "Times New Roman"])
		_serif.font_italic = true
		_serif.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
		_serif.hinting = TextServer.HINTING_LIGHT
	return _serif

static func width(s: String, size: int, use_serif: bool = false) -> float:
	var f := serif() if use_serif else sans()
	return f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x

static func draw(c: CanvasItem, s: String, x: float, y: float, size: int, col: Color, use_serif: bool = false, shadow: bool = true) -> void:
	var f := serif() if use_serif else sans()
	var base := Vector2(roundf(x), roundf(y + f.get_ascent(size)))
	if shadow:
		var oc := Color(0, 0, 0, col.a * 0.75)
		for o in [Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1), Vector2(0, 2)]:
			c.draw_string(f, base + o, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, oc)
	c.draw_string(f, base, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

static func draw_right(c: CanvasItem, s: String, right: float, y: float, size: int, col: Color, use_serif: bool = false, shadow: bool = true) -> void:
	draw(c, s, right - width(s, size, use_serif), y, size, col, use_serif, shadow)

static func draw_center(c: CanvasItem, s: String, cx: float, y: float, size: int, col: Color, use_serif: bool = false, shadow: bool = true) -> void:
	draw(c, s, cx - width(s, size, use_serif) / 2.0, y, size, col, use_serif, shadow)

static func line_h(size: int) -> float:
	return sans().get_height(size)

static func wrap(s: String, max_w: float, size: int, use_serif: bool = false) -> Array:
	var lines: Array = []
	var cur := ""
	for word in s.split(" "):
		var trial: String = word if cur == "" else cur + " " + word
		if width(trial, size, use_serif) > max_w and cur != "":
			lines.append(cur)
			cur = word
		else:
			cur = trial
	if cur != "":
		lines.append(cur)
	return lines
