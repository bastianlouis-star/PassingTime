extends SceneTree
# Paints the game icon: the old man looking up at a clock set to 8:00 (the hour the game
# starts). Large sizes are painted in detail, small sizes (16/24/32, "small icons" view in
# Windows) are drawn separately and simply so they stay readable.
#   godot --headless --path godot --script tools/make_icon.gd
# Writes godot/icon.png and godot/icon.ico.

const BIG := 256

func _initialize() -> void:
	var base := ProjectSettings.globalize_path("res://")
	var big := _paint_big()
	big.save_png(base.path_join("icon.png"))
	var entries: Array = []        # [size, bytes]
	for s in [16, 20, 24, 32, 40, 48]:
		entries.append([s, _dib(_paint_small(s))])
	for s in [64, 96, 128]:
		var im := big.duplicate() as Image
		im.resize(s, s, Image.INTERPOLATE_LANCZOS)
		entries.append([s, im.save_png_to_buffer()])
	entries.append([256, big.save_png_to_buffer()])
	var out := PackedByteArray()
	out.resize(6 + 16 * entries.size())
	out.encode_u16(2, 1)
	out.encode_u16(4, entries.size())
	var offset := 6 + 16 * entries.size()
	for i in entries.size():
		var s: int = entries[i][0]
		var data: PackedByteArray = entries[i][1]
		var o := 6 + 16 * i
		out[o] = 0 if s >= 256 else s
		out[o + 1] = 0 if s >= 256 else s
		out.encode_u16(o + 4, 1)
		out.encode_u16(o + 6, 32)
		out.encode_u32(o + 8, data.size())
		out.encode_u32(o + 12, offset)
		offset += data.size()
	for e in entries:
		out.append_array(e[1])
	var f := FileAccess.open(base.path_join("icon.ico"), FileAccess.WRITE)
	f.store_buffer(out)
	f.close()
	print("wrote icon.png and icon.ico (", entries.size(), " sizes, ", out.size(), " bytes)")
	quit(0)

# ---------------------------------------------------------------- helpers
func _mask_round(img: Image, rad: float) -> void:
	var n := img.get_width()
	for y in n:
		for x in n:
			var q := Vector2(absf(x + 0.5 - n / 2.0), absf(y + 0.5 - n / 2.0)) - Vector2(n / 2.0 - rad, n / 2.0 - rad)
			var d := Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() + minf(maxf(q.x, q.y), 0.0) - rad
			var c := img.get_pixel(x, y)
			c.a *= clampf(0.5 - d, 0.0, 1.0)
			img.set_pixel(x, y, c)

# 32-bit BMP/DIB payload for an ICO entry (BGRA, bottom-up, plus an empty AND mask)
func _dib(img: Image) -> PackedByteArray:
	var n := img.get_width()
	var row_mask := ((n + 31) / 32) * 4
	var out := PackedByteArray()
	out.resize(40 + n * n * 4 + row_mask * n)
	out.encode_u32(0, 40)
	out.encode_s32(4, n)
	out.encode_s32(8, n * 2)
	out.encode_u16(12, 1)
	out.encode_u16(14, 32)
	out.encode_u32(20, n * n * 4 + row_mask * n)
	var p := 40
	for y in range(n - 1, -1, -1):
		for x in n:
			var c := img.get_pixel(x, y)
			out[p] = int(round(c.b * 255.0))
			out[p + 1] = int(round(c.g * 255.0))
			out[p + 2] = int(round(c.r * 255.0))
			out[p + 3] = int(round(c.a * 255.0))
			p += 4
	return out

func _background(p: Painter, glow: Vector2, glow_r: float) -> void:
	var n := p.w
	for y in n:
		for x in n:
			var t := float(y) / n
			var c := Color("2f3f8a").lerp(Color("0d1130"), t)
			var d := Vector2(x - glow.x, y - glow.y).length() / glow_r
			c = c.lerp(Color("c8782a"), clampf(1.0 - d, 0.0, 1.0) * 0.36)
			p.img.set_pixel(x, y, c)

func _clock(p: Painter, c0: Vector2, r: float, detail: bool) -> void:
	p.ellipse(c0.x + r * 0.04, c0.y + r * 0.09, r, r, Color(0, 0, 0), 0.0, 0.35)
	p.ellipse(c0.x, c0.y, r, r, Color("b9852f"), 0.7)
	p.ellipse(c0.x, c0.y, r * 0.89, r * 0.89, Color("e0b252"), 0.5)
	p.ellipse(c0.x, c0.y, r * 0.83, r * 0.83, Color("f2ead2"), 0.35)
	var ticks := 12 if detail else 4
	for k in ticks:
		var a := k * TAU / ticks
		var dir := Vector2(sin(a), -cos(a))
		var thick := (r * 0.065) if (k % 3 == 0 or not detail) else r * 0.032
		p.stroke(c0 + dir * r * 0.65, c0 + dir * r * 0.77, thick, Color("2a2a3a"))
	var ha := deg_to_rad(240.0)
	var hdir := Vector2(sin(ha), -cos(ha))
	var hw := maxf(r * 0.11, 1.4)
	p.stroke(c0, c0 + hdir * r * 0.48, hw, Color("1c1a2a"))
	p.stroke(c0, c0 + Vector2(0, -1) * r * 0.68, maxf(r * 0.075, 1.2), Color("1c1a2a"))
	p.ellipse(c0.x, c0.y, maxf(r * 0.08, 1.2), maxf(r * 0.08, 1.2), Color("b13e53"), 0.6)

# --------------------------------------------------------- the detailed icon
func _paint_big() -> Image:
	var p := Painter.new(BIG, BIG)
	_background(p, Vector2(165, 100), 170.0)
	for i in 22:
		var sx := int(Tex.n2(i, 1, 5) * (BIG - 20)) + 10
		var sy := int(Tex.n2(i, 2, 5) * 70) + 8
		var rr := 1.2 + Tex.n2(i, 3, 5) * 1.1
		p.ellipse(sx, sy, rr, rr, Color(1, 1, 0.95), 0.0, 0.5 + Tex.n2(i, 4, 5) * 0.5)
	_clock(p, Vector2(168, 98), 74.0, true)
	p.ellipse(142, 70, 28, 14, Color(1, 1, 1), 0.0, 0.14)
	# the old man, bust only, looking up and to the right at the clock
	var hero: Image = (Sprites.make(4, "idle") as ImageTexture).get_image()
	var sc := 3.0
	var scaled := hero.duplicate() as Image
	scaled.resize(int(hero.get_width() * sc), int(hero.get_height() * sc), Image.INTERPOLATE_LANCZOS)
	var head := Vector2(45, 18) * sc
	var dest := Vector2(78, 178) - head
	p.img.blend_rect(scaled, Rect2i(0, 0, scaled.get_width(), scaled.get_height()), Vector2i(int(dest.x), int(dest.y)))
	_mask_round(p.img, 52.0)
	return p.img

# ---------------------------------- simple icon for 16..48 px ("small icons")
func _paint_small(n: int) -> Image:
	var k := float(n) / 32.0
	var p := Painter.new(n, n)
	_background(p, Vector2(21, 12) * k, 24.0 * k)
	_clock(p, Vector2(21.5, 12.5) * k, 10.5 * k, n >= 32)
	# shoulders, head, grey hair, white beard, an eye, and a nose pointing at the clock
	p.ellipse(9 * k, 35 * k, 11.5 * k, 8 * k, Color("4d66b0"), 0.5)
	p.ellipse(8.5 * k, 22.5 * k, 6.4 * k, 7.0 * k, Color("e8b98f"), 0.5)
	p.ellipse(14.6 * k, 23.0 * k, 1.5 * k, 1.8 * k, Color("e8b98f"), 0.4)
	p.ellipse(7.6 * k, 18.0 * k, 7.0 * k, 4.4 * k, Color("c4c6d4"), 0.5)
	p.ellipse(10.2 * k, 27.6 * k, 5.4 * k, 5.2 * k, Color("f0f0f6"), 0.4)
	p.ellipse(11.6 * k, 21.4 * k, maxf(0.9 * k, 0.8), maxf(0.9 * k, 0.8), Color("14182a"), 0.0)
	_mask_round(p.img, 7.0 * k)
	return p.img
