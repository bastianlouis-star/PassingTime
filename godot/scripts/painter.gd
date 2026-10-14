class_name Painter
extends RefCounted
# A tiny software painter: anti-aliased ellipses, capsules and polygons with simple
# top-left lighting, composited into an RGBA image. Used to paint the hero.

var img: Image
var w: int
var h: int
var light := Vector2(-0.55, -0.8).normalized()

func _init(width: int, height: int) -> void:
	w = width
	h = height
	img = Image.create(w, h, false, Image.FORMAT_RGBA8)

static func _hash(x: int, y: int) -> float:
	var n := (x * 374761393 + y * 668265263) & 0x7fffffff
	n = ((n ^ (n >> 13)) * 1274126177) & 0x7fffffff
	return float((n ^ (n >> 16)) & 0xffff) / 65535.0

func _blend(x: int, y: int, col: Color, a: float) -> void:
	if x < 0 or y < 0 or x >= w or y >= h or a <= 0.003:
		return
	var d := img.get_pixel(x, y)
	var oa := a + d.a * (1.0 - a)
	if oa <= 0.0:
		return
	var r := (col.r * a + d.r * d.a * (1.0 - a)) / oa
	var g := (col.g * a + d.g * d.a * (1.0 - a)) / oa
	var b := (col.b * a + d.b * d.a * (1.0 - a)) / oa
	img.set_pixel(x, y, Color(r, g, b, oa))

func _shade(base: Color, l: float, k: float, x: int, y: int) -> Color:
	var c := base
	if l > 0.0:
		c = base.lerp(Color(1, 1, 1), l * k * 0.55)
	else:
		c = base.lerp(Color(0.05, 0.04, 0.12), -l * k)
	var n := (_hash(x, y) - 0.5) * 0.035
	return Color(clampf(c.r + n, 0, 1), clampf(c.g + n, 0, 1), clampf(c.b + n, 0, 1), base.a)

func ellipse(cx: float, cy: float, rx: float, ry: float, base: Color, k: float = 0.5, alpha: float = 1.0) -> void:
	for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
		for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			var ln := sqrt(dx * dx + dy * dy)
			var dist := (ln - 1.0) * minf(rx, ry)
			var cov := clampf(0.5 - dist, 0.0, 1.0)
			if cov <= 0.0:
				continue
			var n := Vector2(dx, dy)
			var l := 0.0
			if n.length() > 0.001:
				l = n.normalized().dot(light) * clampf(ln, 0.0, 1.0)
			_blend(x, y, _shade(base, l, k, x, y), cov * alpha)

func capsule(a: Vector2, b: Vector2, ra: float, rb: float, base: Color, k: float = 0.5, alpha: float = 1.0) -> void:
	var minx := int(minf(a.x - ra, b.x - rb)) - 1
	var maxx := int(maxf(a.x + ra, b.x + rb)) + 2
	var miny := int(minf(a.y - ra, b.y - rb)) - 1
	var maxy := int(maxf(a.y + ra, b.y + rb)) + 2
	var ab := b - a
	var ab2 := maxf(ab.length_squared(), 0.0001)
	for y in range(miny, maxy):
		for x in range(minx, maxx):
			var p := Vector2(x + 0.5, y + 0.5)
			var t := clampf((p - a).dot(ab) / ab2, 0.0, 1.0)
			var c := a + ab * t
			var r := lerpf(ra, rb, t)
			var dist := p.distance_to(c) - r
			var cov := clampf(0.5 - dist, 0.0, 1.0)
			if cov <= 0.0:
				continue
			var n := (p - c)
			var l := 0.0
			if n.length() > 0.001:
				l = (n / maxf(r, 0.001)).limit_length(1.0).dot(light)
			_blend(x, y, _shade(base, l, k, x, y), cov * alpha)

func stroke(a: Vector2, b: Vector2, wd: float, col: Color) -> void:
	var minx := int(minf(a.x, b.x) - wd) - 1
	var maxx := int(maxf(a.x, b.x) + wd) + 2
	var miny := int(minf(a.y, b.y) - wd) - 1
	var maxy := int(maxf(a.y, b.y) + wd) + 2
	var ab := b - a
	var ab2 := maxf(ab.length_squared(), 0.0001)
	for y in range(miny, maxy):
		for x in range(minx, maxx):
			var p := Vector2(x + 0.5, y + 0.5)
			var t := clampf((p - a).dot(ab) / ab2, 0.0, 1.0)
			var dist := p.distance_to(a + ab * t) - wd * 0.5
			var cov := clampf(0.5 - dist, 0.0, 1.0)
			_blend(x, y, col, cov * col.a)

func poly(pts: Array, base: Color, k: float = 0.5, alpha: float = 1.0) -> void:
	var minx := 1000000.0
	var maxx := -1000000.0
	var miny := 1000000.0
	var maxy := -1000000.0
	for p in pts:
		var v: Vector2 = p
		minx = minf(minx, v.x)
		maxx = maxf(maxx, v.x)
		miny = minf(miny, v.y)
		maxy = maxf(maxy, v.y)
	var cx := (minx + maxx) / 2.0
	var cy := (miny + maxy) / 2.0
	var hw := maxf((maxx - minx) / 2.0, 1.0)
	var hh := maxf((maxy - miny) / 2.0, 1.0)
	var n := pts.size()
	for y in range(int(miny) - 1, int(maxy) + 2):
		for x in range(int(minx) - 1, int(maxx) + 2):
			var p := Vector2(x + 0.5, y + 0.5)
			var inside := false
			var best := 1000000.0
			for i in n:
				var a: Vector2 = pts[i]
				var b: Vector2 = pts[(i + 1) % n]
				if ((a.y > p.y) != (b.y > p.y)) and (p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x):
					inside = not inside
				var ab := b - a
				var t := clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
				best = minf(best, p.distance_to(a + ab * t))
			var sd := -best if inside else best
			var cov := clampf(0.5 - sd, 0.0, 1.0)
			if cov <= 0.0:
				continue
			var q := Vector2((x - cx) / hw, (y - cy) / hh)
			var l := Vector2(q.x * 0.9, q.y * 0.35).limit_length(1.0).dot(light)
			_blend(x, y, _shade(base, l, k, x, y), cov * alpha)

# dark rim around everything painted so far (keeps him readable on any background)
func outline(col: Color) -> void:
	var src := img.duplicate() as Image
	for y in h:
		for x in w:
			if src.get_pixel(x, y).a > 0.25:
				continue
			var best := 0.0
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < w and ny < h:
					best = maxf(best, src.get_pixel(nx, ny).a * (1.0 if absi(d.x) + absi(d.y) == 1 else 0.6))
			if best > 0.3:
				img.set_pixel(x, y, Color(col.r, col.g, col.b, clampf(best, 0.0, 1.0) * col.a))

func texture() -> ImageTexture:
	return ImageTexture.create_from_image(img)
