class_name Tex
extends RefCounted
# Procedural pixel-art textures (no image files). Everything is painted at start-up
# into small nearest-filtered images that tile on 3D surfaces.

static var _cache := {}

# ------------------------------------------------------------------- noise

static func n2(x: int, y: int, s: int = 0) -> float:
	var h := (x * 374761393 + y * 668265263 + s * 1274126177) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return float((h ^ (h >> 16)) & 0xffff) / 65535.0

static func vn(x: float, y: float, s: int = 0) -> float:
	var xi := int(floorf(x))
	var yi := int(floorf(y))
	var fx := x - xi
	var fy := y - yi
	fx = fx * fx * (3.0 - 2.0 * fx)
	fy = fy * fy * (3.0 - 2.0 * fy)
	var a := n2(xi, yi, s)
	var b := n2(xi + 1, yi, s)
	var c := n2(xi, yi + 1, s)
	var d := n2(xi + 1, yi + 1, s)
	return lerpf(lerpf(a, b, fx), lerpf(c, d, fx), fy)

# tileable fractal noise over a w x h grid
static func tn(x: int, y: int, w: int, h: int, scale: float, s: int) -> float:
	var fx := float(x) / w * scale
	var fy := float(y) / h * scale
	var sc := int(scale)
	var xi := int(floorf(fx))
	var yi := int(floorf(fy))
	var tx := fx - xi
	var ty := fy - yi
	tx = tx * tx * (3.0 - 2.0 * tx)
	ty = ty * ty * (3.0 - 2.0 * ty)
	var a := n2(posmod(xi, sc), posmod(yi, sc), s)
	var b := n2(posmod(xi + 1, sc), posmod(yi, sc), s)
	var c := n2(posmod(xi, sc), posmod(yi + 1, sc), s)
	var d := n2(posmod(xi + 1, sc), posmod(yi + 1, sc), s)
	return lerpf(lerpf(a, b, tx), lerpf(c, d, tx), ty)

static func _img(w: int, h: int) -> Image:
	return Image.create(w, h, false, Image.FORMAT_RGBA8)

static func _tex(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)

# ----------------------------------------------------------------- surfaces

static func wood_floor() -> ImageTexture:
	if _cache.has("wood_floor"):
		return _cache["wood_floor"]
	var w := 64
	var h := 64
	var img := _img(w, h)
	var cols := [Color("8a5a3a"), Color("7a4c30"), Color("93623e"), Color("6f4429")]
	for p in 8:
		var base: Color = cols[int(n2(p, 3, 1) * cols.size())]
		var joint := int(n2(p, 9, 2) * w)
		for y in 8:
			for x in w:
				var yy := p * 8 + y
				var grain := tn(x, yy, w, h, 8.0, p + 5) * 0.5 + tn(x * 4 % w, yy, w, h, 16.0, p + 9) * 0.5
				var col := base.lightened((grain - 0.5) * 0.28)
				if y == 0:
					col = col.darkened(0.45)
				elif y == 1:
					col = col.lightened(0.12)
				elif y == 7:
					col = col.darkened(0.18)
				if x == joint:
					col = col.darkened(0.5)
				if n2(x, yy, 7) > 0.985:
					col = col.darkened(0.3)
				img.set_pixel(x, yy, col)
	_cache["wood_floor"] = _tex(img)
	return _cache["wood_floor"]

static func wood(base_hex: String = "6b3f2a", key: String = "") -> ImageTexture:
	var k := "wood_" + base_hex + key
	if _cache.has(k):
		return _cache[k]
	var w := 32
	var h := 32
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 4.0, 3) * 0.6 + tn(x * 2 % w, y, w, h, 8.0, 4) * 0.4
			var col := base.lightened((g - 0.5) * 0.3)
			if (y + int(n2(x / 8, 1, 5) * 3)) % 5 == 0:
				col = col.darkened(0.12)
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func wallpaper() -> ImageTexture:
	if _cache.has("wallpaper"):
		return _cache["wallpaper"]
	var w := 64
	var h := 64
	var img := _img(w, h)
	for y in h:
		for x in w:
			var stripe := (x / 8) % 2
			var col := Color("3b4668") if stripe == 0 else Color("343e5f")
			col = col.lightened((tn(x, y, w, h, 8.0, 21) - 0.5) * 0.08)
			# damask-like motifs
			for c in [Vector2(16, 14), Vector2(48, 46)]:
				var dx := absf(x - c.x)
				var dy := absf(y - c.y)
				var dd := dx + dy * 1.2
				if dd < 6.0 and dd > 4.2:
					col = Color("55609a")
				elif dd <= 4.2 and dd > 3.0:
					col = col.lightened(0.04)
				elif dd < 1.6:
					col = Color("66729f")
			if x % 8 == 0:
				col = col.darkened(0.12)
			img.set_pixel(x, y, col)
	_cache["wallpaper"] = _tex(img)
	return _cache["wallpaper"]

static func wainscot() -> ImageTexture:
	if _cache.has("wainscot"):
		return _cache["wainscot"]
	var w := 64
	var h := 64
	var img := _img(w, h)
	for y in h:
		for x in w:
			var col := Color("2b3150")
			var px := x % 32
			var inset := px > 3 and px < 28 and y > 6 and y < 58
			if inset:
				col = Color("2f3556")
				if px == 4 or y == 7:
					col = col.darkened(0.25)
				if px == 27 or y == 57:
					col = col.lightened(0.18)
			elif px == 0 or px == 31:
				col = col.darkened(0.2)
			col = col.lightened((tn(x, y, w, h, 8.0, 31) - 0.5) * 0.06)
			img.set_pixel(x, y, col)
	_cache["wainscot"] = _tex(img)
	return _cache["wainscot"]

static func rug() -> ImageTexture:
	if _cache.has("rug"):
		return _cache["rug"]
	var w := 128
	var h := 64
	var img := _img(w, h)
	for y in h:
		for x in w:
			var col := Color("7a2a3a")
			var bx := mini(x, w - 1 - x)
			var by := mini(y, h - 1 - y)
			var b := mini(bx, by * 2)
			if b < 3:
				col = Color("c8a060")
			elif b < 6:
				col = Color("5a1c2a")
			elif b < 8:
				col = Color("c8a060") if (x + y) % 4 < 2 else Color("8a2a3a")
			else:
				var cx := (x - w / 2.0) / 40.0
				var cy := (y - h / 2.0) / 14.0
				var r := sqrt(cx * cx + cy * cy)
				if r < 0.28:
					col = Color("e8c070")
				elif r < 0.5:
					col = Color("b4402a")
				elif r < 0.62 and (int(r * 40) % 2 == 0):
					col = Color("e0a050")
				else:
					var dx := (x % 16) - 8
					var dy := (y % 16) - 8
					if absi(dx) + absi(dy) < 4:
						col = Color("a03a2a")
					elif absi(dx) + absi(dy) == 5:
						col = Color("c88a40")
			col = col.lightened((n2(x, y, 44) - 0.5) * 0.08)
			img.set_pixel(x, y, col)
	_cache["rug"] = _tex(img)
	return _cache["rug"]

static func plaster(base_hex: String = "c8bfa8") -> ImageTexture:
	var k := "plaster_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 64
	var h := 64
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 8.0, 12) * 0.6 + tn(x, y, w, h, 16.0, 13) * 0.4
			var col := base.lightened((g - 0.5) * 0.18)
			if n2(x, y, 6) > 0.97:
				col = col.darkened(0.12)
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func flagstone(base_hex: String = "8a8478") -> ImageTexture:
	var k := "flag_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 64
	var h := 64
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var row := y / 16
			var xo := x + (row % 2) * 16
			var cx := xo / 32
			var local_x := xo % 32
			var local_y := y % 16
			var sid := cx * 7 + row * 13
			var col := base.lightened((n2(sid, 3, 8) - 0.5) * 0.18)
			col = col.lightened((tn(x, y, w, h, 16.0, 17) - 0.5) * 0.14)
			if local_x == 0 or local_y == 0:
				col = col.darkened(0.45)
			elif local_x == 1 or local_y == 1:
				col = col.lightened(0.12)
			elif n2(x, y, 9) > 0.96:
				col = col.darkened(0.15)
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func brick(base_hex: String = "9a5a46") -> ImageTexture:
	var k := "brick_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 64
	var h := 64
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var row := y / 8
			var xo := x + (row % 2) * 8
			var bid := (xo / 16) + row * 5
			var col := base.lightened((n2(bid, 5, 3) - 0.5) * 0.3)
			col = col.lightened((n2(x, y, 4) - 0.5) * 0.08)
			if y % 8 == 0 or xo % 16 == 0:
				col = Color("5a4a40")
			elif y % 8 == 1:
				col = col.lightened(0.12)
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func grass() -> ImageTexture:
	if _cache.has("grass"):
		return _cache["grass"]
	var w := 64
	var h := 64
	var img := _img(w, h)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 8.0, 41) * 0.5 + tn(x, y, w, h, 16.0, 42) * 0.3 + n2(x, y, 43) * 0.2
			var col := Color("2a5a32").lerp(Color("3f7a3a"), g)
			if n2(x, y, 44) > 0.93:
				col = Color("5a9448")
			elif n2(x, y, 45) > 0.9:
				col = Color("1f4a2a")
			img.set_pixel(x, y, col)
	_cache["grass"] = _tex(img)
	return _cache["grass"]

static func dirt() -> ImageTexture:
	if _cache.has("dirt"):
		return _cache["dirt"]
	var w := 64
	var h := 64
	var img := _img(w, h)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 8.0, 51) * 0.6 + tn(x, y, w, h, 16.0, 52) * 0.4
			var col := Color("8a6a46").lerp(Color("a88860"), g)
			if n2(x, y, 53) > 0.95:
				col = Color("5a4630")
			elif n2(x, y, 54) > 0.94:
				col = Color("c4a880")
			img.set_pixel(x, y, col)
	_cache["dirt"] = _tex(img)
	return _cache["dirt"]

static func bark() -> ImageTexture:
	if _cache.has("bark"):
		return _cache["bark"]
	var w := 32
	var h := 64
	var img := _img(w, h)
	for y in h:
		for x in w:
			var g := tn(x * 2, y, w * 2, h, 6.0, 61)
			var col := Color("5a3a28").lerp(Color("7a5438"), g)
			if (x + int(n2(y / 8, 2, 62) * 4)) % 4 == 0:
				col = col.darkened(0.35)
			img.set_pixel(x, y, col)
	_cache["bark"] = _tex(img)
	return _cache["bark"]

static func shingles(base_hex: String = "8a3a3a") -> ImageTexture:
	var k := "shingle_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 64
	var h := 64
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var row := y / 8
			var xo := x + (row % 2) * 8
			var sid := (xo / 16) + row * 4
			var col := base.lightened((n2(sid, 2, 71) - 0.5) * 0.28)
			var ly := y % 8
			if ly == 7:
				col = col.darkened(0.5)
			elif ly > 4:
				col = col.darkened(0.12)
			elif ly == 0:
				col = col.lightened(0.12)
			if xo % 16 == 0:
				col = col.darkened(0.3)
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func planks_v(base_hex: String = "7a4c32") -> ImageTexture:
	var k := "planksv_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 64
	var h := 64
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var p := x / 8
			var col := base.lightened((n2(p, 4, 81) - 0.5) * 0.25)
			col = col.lightened((tn(x, y * 2 % h, w, h, 12.0, 82 + p) - 0.5) * 0.2)
			if x % 8 == 0:
				col = col.darkened(0.5)
			elif x % 8 == 1:
				col = col.lightened(0.1)
			if y % 32 == 14 and x % 8 == 4:
				col = col.darkened(0.5)
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func strata() -> ImageTexture:
	if _cache.has("strata"):
		return _cache["strata"]
	var w := 64
	var h := 64
	var img := _img(w, h)
	var cols := [Color("8a5a3a"), Color("b07a4a"), Color("6a4030"), Color("c89a5a"), Color("7a4a38"), Color("a0663e"), Color("d0b080")]
	var y := 0
	var i := 0
	while y < h:
		var bh := 3 + int(n2(i, 1, 91) * 6)
		var col: Color = cols[int(n2(i, 2, 92) * cols.size())]
		for yy in range(y, mini(y + bh, h)):
			for x in w:
				var c := col.lightened((tn(x, yy, w, h, 8.0, 93) - 0.5) * 0.2)
				if yy == y:
					c = c.lightened(0.15)
				if n2(x, yy, 94) > 0.97:
					c = c.darkened(0.2)
				img.set_pixel(x, yy, c)
		y += bh
		i += 1
	_cache["strata"] = _tex(img)
	return _cache["strata"]

static func metal(base_hex: String = "3a3d4c") -> ImageTexture:
	var k := "metal_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 32
	var h := 32
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var col := base.lightened((tn(x, y, w, h, 4.0, 95) - 0.5) * 0.2)
			if n2(x, y, 96) > 0.95:
				col = col.lightened(0.15)
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func radial(col: Color, soft: float = 1.0) -> ImageTexture:
	var k := "radial_%s_%s" % [col.to_html(), soft]
	if _cache.has(k):
		return _cache[k]
	var n := 64
	var img := _img(n, n)
	for y in n:
		for x in n:
			var d := Vector2(x + 0.5 - n / 2.0, y + 0.5 - n / 2.0).length() / (n / 2.0)
			var a := clampf(1.0 - d, 0.0, 1.0)
			a = pow(a, soft)
			img.set_pixel(x, y, Color(col.r, col.g, col.b, a * col.a))
	_cache[k] = _tex(img)
	return _cache[k]

# gradient sky strip used for the glass of windows etc. (vertical)
static func vgrad(top: Color, bot: Color, key: String) -> ImageTexture:
	var img := _img(4, 64)
	for y in 64:
		var c := top.lerp(bot, float(y) / 63.0)
		for x in 4:
			img.set_pixel(x, y, c)
	return _tex(img)


# ---------------------------------------------------------- outdoor sprites

static func leaves(base_hex: String = "2f7a3a") -> ImageTexture:
	var k := "leaves_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 32
	var h := 32
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 8.0, 101) * 0.5 + tn(x, y, w, h, 16.0, 102) * 0.5
			var col := base.darkened(0.25).lerp(base.lightened(0.25), g)
			if n2(x, y, 103) > 0.9:
				col = base.lightened(0.4)
			elif n2(x, y, 104) > 0.88:
				col = base.darkened(0.45)
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func cloud() -> ImageTexture:
	if _cache.has("cloud"):
		return _cache["cloud"]
	var w := 128
	var h := 48
	var img := _img(w, h)
	for y in h:
		for x in w:
			var d := 0.0
			for b in [Vector3(36, 30, 20), Vector3(58, 22, 22), Vector3(82, 28, 18), Vector3(100, 32, 12), Vector3(20, 34, 12)]:
				var dx: float = (x - b.x) / b.z
				var dy: float = (y - b.y) / (b.z * 0.62)
				d = maxf(d, 1.0 - sqrt(dx * dx + dy * dy))
			var a := clampf(d * 3.0, 0.0, 1.0)
			a *= 0.55 + 0.45 * tn(x, y, w, h, 8.0, 111)
			var shade := clampf(float(y) / h, 0.0, 1.0)
			var col := Color(1, 1, 1).lerp(Color(0.72, 0.78, 0.9), shade * 0.8)
			if a > 0.5:
				a = 1.0
			elif a > 0.25:
				a = 0.6
			else:
				a = 0.0
			img.set_pixel(x, y, Color(col.r, col.g, col.b, a))
	_cache["cloud"] = _tex(img)
	return _cache["cloud"]

static func stars_dome() -> ImageTexture:
	if _cache.has("stars_dome"):
		return _cache["stars_dome"]
	var w := 1024
	var h := 512
	var img := _img(w, h)
	for i in 700:
		var x := int(n2(i, 1, 121) * w)
		var y := int(n2(i, 2, 121) * h * 0.85)
		var b := n2(i, 3, 121)
		var col := Color(1, 1, 1, 0.5 + b * 0.5) if b > 0.3 else Color(0.8, 0.88, 1.0, 0.45)
		img.set_pixel(x, y, col)
		if b > 0.92:
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				img.set_pixel(clampi(x + d.x, 0, w - 1), clampi(y + d.y, 0, h - 1), Color(1, 1, 1, 0.35))
	_cache["stars_dome"] = _tex(img)
	return _cache["stars_dome"]

static func tuft(base_hex: String = "3a8a40") -> ImageTexture:
	var k := "tuft_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 16
	var h := 16
	var img := _img(w, h)
	var base := Color(base_hex)
	for b in 7:
		var bx := 2 + int(n2(b, 1, 131) * 12)
		var bh := 6 + int(n2(b, 2, 131) * 9)
		var lean := (n2(b, 3, 131) - 0.5) * 0.5
		for y in bh:
			var xx := bx + int(lean * y)
			if xx >= 0 and xx < w:
				var c := base.lerp(base.lightened(0.45), float(y) / bh)
				img.set_pixel(xx, h - 1 - y, c)
				if y < bh - 2 and xx + 1 < w:
					img.set_pixel(xx + 1, h - 1 - y, c.darkened(0.25))
	_cache[k] = _tex(img)
	return _cache[k]

static func flower(col: Color) -> ImageTexture:
	var k := "flower_" + col.to_html()
	if _cache.has(k):
		return _cache[k]
	var img := _img(9, 14)
	for y in range(5, 14):
		img.set_pixel(4, y, Color("3a8a40"))
	img.set_pixel(3, 9, Color("3a8a40"))
	img.set_pixel(5, 11, Color("3a8a40"))
	for d in [Vector2i(4, 2), Vector2i(3, 3), Vector2i(5, 3), Vector2i(4, 4), Vector2i(2, 3), Vector2i(6, 3), Vector2i(3, 2), Vector2i(5, 2), Vector2i(3, 4), Vector2i(5, 4)]:
		img.set_pixel(d.x, d.y, col)
	img.set_pixel(4, 3, Color("ffe080"))
	_cache[k] = _tex(img)
	return _cache[k]

static func snow(base_hex: String = "e8f0f8") -> ImageTexture:
	var k := "snow_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 32
	var h := 32
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 4.0, 141)
			var col := base.darkened(0.12).lerp(base, g)
			if n2(x, y, 142) > 0.95:
				col = Color.WHITE
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func ice() -> ImageTexture:
	if _cache.has("ice"):
		return _cache["ice"]
	var w := 32
	var h := 32
	var img := _img(w, h)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 4.0, 151) * 0.6 + tn(x, y, w, h, 8.0, 152) * 0.4
			var col := Color("8ac0e0").lerp(Color("e0f4ff"), g)
			if absf(sin((x + y * 0.6) * 0.5)) > 0.96:
				col = Color.WHITE
			img.set_pixel(x, y, col)
	_cache["ice"] = _tex(img)
	return _cache["ice"]

static func marble() -> ImageTexture:
	if _cache.has("marble"):
		return _cache["marble"]
	var w := 32
	var h := 32
	var img := _img(w, h)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 4.0, 161)
			var col := Color("d8d0c0").lerp(Color("f0e8d8"), g)
			if absf(sin(x * 0.4 + tn(x, y, w, h, 4.0, 162) * 5.0)) > 0.97:
				col = Color("a8a090")
			img.set_pixel(x, y, col)
	_cache["marble"] = _tex(img)
	return _cache["marble"]


static func hand(col: Color) -> ImageTexture:
	var k := "hand_" + col.to_html()
	if _cache.has(k):
		return _cache[k]
	var img := _img(12, 14)
	for y in range(7, 14):
		for x in range(3, 9):
			img.set_pixel(x, y, col)
	for f in [Vector2i(3, 2), Vector2i(5, 0), Vector2i(7, 1), Vector2i(9, 3)]:
		for y in range(f.y, 8):
			img.set_pixel(f.x, y, col)
			if f.x + 1 < 12:
				img.set_pixel(f.x + 1, y, col)
	for y in range(8, 11):
		img.set_pixel(1, y, col)
		img.set_pixel(2, y, col)
	_cache[k] = _tex(img)
	return _cache[k]

static func canvas_art(seed_v: int) -> ImageTexture:
	var k := "canvas_%d" % seed_v
	if _cache.has(k):
		return _cache[k]
	var img := _img(12, 12)
	var a := Color.from_hsv(n2(seed_v, 1, 171), 0.55, 0.9)
	var b := Color.from_hsv(fposmod(n2(seed_v, 1, 171) + 0.4, 1.0), 0.6, 0.8)
	for y in 12:
		for x in 12:
			var c := a.lerp(b, float(y) / 11.0)
			if Vector2(x - 6 + n2(seed_v, 2, 172) * 4 - 2, y - 6).length() < 3.5:
				c = Color.from_hsv(n2(seed_v, 3, 173), 0.7, 1.0)
			img.set_pixel(x, y, c)
	_cache[k] = _tex(img)
	return _cache[k]


static func figure(coat: Color, hair: Color) -> ImageTexture:
	var k := "figure_%s_%s" % [coat.to_html(), hair.to_html()]
	if _cache.has(k):
		return _cache[k]
	var img := _img(7, 14)
	for y in range(0, 3):
		for x in range(2, 5):
			img.set_pixel(x, y, hair if y == 0 else Color("e8b98f"))
	for y in range(3, 9):
		for x in range(1, 6):
			img.set_pixel(x, y, coat)
	for y in range(9, 14):
		img.set_pixel(2, y, Color("343a5a"))
		img.set_pixel(4, y, Color("343a5a"))
	_cache[k] = _tex(img)
	return _cache[k]

static func bone() -> ImageTexture:
	if _cache.has("bone"):
		return _cache["bone"]
	var img := _img(24, 12)
	for x in range(5, 22):
		img.set_pixel(x, 6, Color("e8e0c8"))
		img.set_pixel(x, 7, Color("c8c0a8"))
	for x in range(8, 20, 3):
		for y in range(3, 10):
			img.set_pixel(x, y, Color("e8e0c8"))
	for p in [Vector2i(3, 4), Vector2i(4, 4), Vector2i(3, 5), Vector2i(4, 5), Vector2i(2, 5), Vector2i(2, 6), Vector2i(3, 7), Vector2i(4, 7)]:
		img.set_pixel(p.x, p.y, Color("f0e8d0"))
	img.set_pixel(3, 5, Color("2a2a30"))
	_cache["bone"] = _tex(img)
	return _cache["bone"]

static func lava() -> ImageTexture:
	if _cache.has("lava"):
		return _cache["lava"]
	var w := 32
	var h := 32
	var img := _img(w, h)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 4.0, 181) * 0.6 + tn(x, y, w, h, 8.0, 182) * 0.4
			var col := Color("3a1208").lerp(Color("ff7a30"), pow(g, 2.0))
			if g > 0.7:
				col = Color("ffd070")
			img.set_pixel(x, y, col)
	_cache["lava"] = _tex(img)
	return _cache["lava"]

static func rockface(base_hex: String = "4a3a40") -> ImageTexture:
	var k := "rockface_" + base_hex
	if _cache.has(k):
		return _cache[k]
	var w := 32
	var h := 32
	var img := _img(w, h)
	var base := Color(base_hex)
	for y in h:
		for x in w:
			var g := tn(x, y, w, h, 4.0, 191) * 0.6 + tn(x, y, w, h, 8.0, 192) * 0.4
			var col := base.darkened(0.2).lerp(base.lightened(0.25), g)
			if n2(x, y, 193) > 0.94:
				col = col.darkened(0.3)
			img.set_pixel(x, y, col)
	_cache[k] = _tex(img)
	return _cache[k]
