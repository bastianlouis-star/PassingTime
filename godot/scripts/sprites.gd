class_name Sprites
extends RefCounted
# The hero, painted procedurally at 80x160 (facing right) with real anatomy, a lit coat,
# a face with eyes and brows, hands, boots and a beard that grows as the eras pass.

const W := 80
const H := 160
const GROUND := 157.0

static var _cache := {}

static func beard_len(era: int) -> float:
	return [0.0, 6.0, 13.0, 22.0, 34.0, 48.0, 48.0, 48.0, 62.0][clampi(era, 0, 8)]

# pose joints: near/far arm = [shoulder, elbow, hand]; near/far leg = [hip, knee, ankle]
static func _joints(pose: String) -> Dictionary:
	var j := {
		"na": [Vector2(36, 46), Vector2(33, 70), Vector2(35, 93)],
		"fa": [Vector2(50, 46), Vector2(55, 70), Vector2(54, 92)],
		"nl": [Vector2(37, 102), Vector2(37, 127), Vector2(37, 150)],
		"fl": [Vector2(46, 102), Vector2(47, 127), Vector2(47, 150)],
		"oy": 0.0,
	}
	match pose:
		"walk_a":
			j["na"] = [Vector2(36, 46), Vector2(30, 68), Vector2(25, 90)]
			j["fa"] = [Vector2(50, 46), Vector2(58, 68), Vector2(64, 88)]
			j["nl"] = [Vector2(37, 102), Vector2(45, 126), Vector2(52, 147)]
			j["fl"] = [Vector2(46, 102), Vector2(40, 124), Vector2(31, 143)]
		"walk_b":
			j["na"] = [Vector2(36, 46), Vector2(33, 70), Vector2(34, 92)]
			j["fa"] = [Vector2(50, 46), Vector2(55, 70), Vector2(55, 92)]
			j["nl"] = [Vector2(38, 102), Vector2(40, 126), Vector2(39, 150)]
			j["fl"] = [Vector2(46, 102), Vector2(50, 122), Vector2(46, 141)]
		"walk_c":
			j["na"] = [Vector2(36, 46), Vector2(39, 68), Vector2(45, 89)]
			j["fa"] = [Vector2(50, 46), Vector2(51, 70), Vector2(47, 92)]
			j["nl"] = [Vector2(37, 102), Vector2(32, 124), Vector2(24, 143)]
			j["fl"] = [Vector2(46, 102), Vector2(53, 126), Vector2(58, 147)]
		"walk_d":
			j["na"] = [Vector2(36, 46), Vector2(33, 70), Vector2(34, 92)]
			j["fa"] = [Vector2(50, 46), Vector2(55, 70), Vector2(55, 92)]
			j["nl"] = [Vector2(38, 102), Vector2(44, 122), Vector2(41, 141)]
			j["fl"] = [Vector2(46, 102), Vector2(47, 126), Vector2(46, 150)]
		"sit":
			j["oy"] = 18.0
			j["na"] = [Vector2(36, 64), Vector2(34, 86), Vector2(50, 101)]
			j["fa"] = [Vector2(50, 64), Vector2(55, 86), Vector2(60, 100)]
			j["nl"] = [Vector2(38, 120), Vector2(60, 119), Vector2(61, 149)]
			j["fl"] = [Vector2(46, 120), Vector2(66, 120), Vector2(67, 150)]
		"read":
			j["oy"] = 18.0
			j["na"] = [Vector2(36, 64), Vector2(40, 87), Vector2(55, 86)]
			j["fa"] = [Vector2(50, 64), Vector2(57, 84), Vector2(61, 78)]
			j["nl"] = [Vector2(38, 120), Vector2(60, 119), Vector2(61, 149)]
			j["fl"] = [Vector2(46, 120), Vector2(66, 120), Vector2(67, 150)]
	return j

static func _boot(p: Painter, a: Vector2, boot: Color, boot_l: Color) -> void:
	p.poly([Vector2(a.x - 6.5, a.y - 12), Vector2(a.x + 5.5, a.y - 12), Vector2(a.x + 6.5, a.y - 3), Vector2(a.x + 15, a.y + 1.5), Vector2(a.x + 16, a.y + 5), Vector2(a.x + 15, a.y + 7), Vector2(a.x - 6.5, a.y + 7)], boot, 0.5)
	p.poly([Vector2(a.x - 6.5, a.y + 5), Vector2(a.x + 15, a.y + 5.5), Vector2(a.x + 15, a.y + 7.5), Vector2(a.x - 6.5, a.y + 7.5)], Color("14100e"), 0.2)
	p.stroke(Vector2(a.x - 5, a.y - 8), Vector2(a.x + 4, a.y - 8), 1.2, Color(boot_l.r, boot_l.g, boot_l.b, 0.55))
	p.stroke(Vector2(a.x + 6, a.y - 1), Vector2(a.x + 13, a.y + 2), 1.0, Color(boot_l.r, boot_l.g, boot_l.b, 0.4))

static func _leg(p: Painter, jn: Array, pants: Color, boot: Color, boot_l: Color) -> void:
	var hip: Vector2 = jn[0]
	var knee: Vector2 = jn[1]
	var ank: Vector2 = jn[2]
	p.capsule(hip, knee, 7.2, 6.2, pants, 0.55)
	p.capsule(knee, ank - Vector2(0, 5), 6.0, 4.6, pants, 0.55)
	p.stroke(knee + Vector2(-3, 1), knee + Vector2(3, 2), 1.2, Color(0, 0, 0, 0.25))
	_boot(p, ank, boot, boot_l)

static func _arm(p: Painter, jn: Array, sleeve: Color, cuff: Color, skin: Color, far: bool) -> void:
	var s: Vector2 = jn[0]
	var e: Vector2 = jn[1]
	var hnd: Vector2 = jn[2]
	var sk := skin.darkened(0.25) if far else skin
	p.capsule(s, e, 6.4, 5.5, sleeve, 0.55)
	p.capsule(e, hnd - (hnd - e).normalized() * 6.0, 5.4, 4.5, sleeve, 0.55)
	var dir := (hnd - e).normalized()
	var cuff_a := hnd - dir * 9.0
	p.capsule(cuff_a, hnd - dir * 5.0, 4.8, 4.9, cuff, 0.5)
	p.ellipse(hnd.x, hnd.y, 4.2, 5.2, sk, 0.5)
	p.capsule(hnd + Vector2(2.4, -2.5), hnd + Vector2(5.0, 1.5), 1.5, 1.2, sk, 0.5)
	p.stroke(hnd + Vector2(-1.5, 1.0), hnd + Vector2(-1.0, 4.0), 0.7, Color(0, 0, 0, 0.2))
	p.stroke(hnd + Vector2(0.2, 1.5), hnd + Vector2(0.6, 4.5), 0.7, Color(0, 0, 0, 0.2))

static func make(era: int, pose: String) -> ImageTexture:
	var key := "%d_%s" % [era, pose]
	if _cache.has(key):
		return _cache[key]
	var p := Painter.new(W, H)
	var gray := era >= 3
	var hair := Color("b9bac6") if gray else Color("5b3a29")
	var hair_d := hair.darkened(0.35)
	var hair_l := hair.lightened(0.28)
	var skin := Color("eebb91")
	var skin_d := Color("c8956f")
	var skin_l := Color("f8d4b0")
	var coat := Color("3f5a9a")
	var coat_l := Color("6a86c8")
	var coat_d := Color("26356a")
	var sleeve := Color("46619f")
	var pants := Color("4a5070")
	var boot := Color("3a2a24")
	var boot_l := Color("7a5a48")
	var bcol := Color("e6e6ee") if era >= 2 else Color("6a4a36")
	var j := _joints(pose)
	var oy: float = j["oy"]
	# ------------------------------------------------ far limbs (behind the body)
	_leg(p, j["fl"], pants.darkened(0.3), boot.darkened(0.25), boot_l.darkened(0.3))
	_arm(p, j["fa"], sleeve.darkened(0.35), coat_l.darkened(0.3), skin, true)
	# ---------------------------------------------------------------- near leg
	_leg(p, j["nl"], pants, boot, boot_l)
	# ------------------------------------------------------------------- coat
	var t0 := 40.0 + oy
	p.poly([Vector2(26, t0 + 1), Vector2(33, t0 - 2), Vector2(50, t0 - 2), Vector2(58, t0 + 2), Vector2(59, t0 + 16),
		Vector2(57, t0 + 46), Vector2(61, t0 + 72), Vector2(21, t0 + 72), Vector2(27, t0 + 46), Vector2(25, t0 + 16)], coat, 0.55)
	# back panel in shadow and the lower skirt
	p.poly([Vector2(21, t0 + 72), Vector2(27, t0 + 46), Vector2(36, t0 + 46), Vector2(34, t0 + 72)], coat_d, 0.3, 0.55)
	# shirt opening and lapels
	p.poly([Vector2(45, t0 - 1), Vector2(51, t0 - 1), Vector2(52, t0 + 8), Vector2(49, t0 + 24)], Color("e8e0cc"), 0.4)
	p.poly([Vector2(44, t0 - 2), Vector2(52, t0), Vector2(57, t0 + 4), Vector2(57, t0 + 30), Vector2(51, t0 + 46), Vector2(48, t0 + 22)], coat_l, 0.5, 0.85)
	p.stroke(Vector2(48, t0 + 22), Vector2(51, t0 + 46), 1.0, Color(coat_d.r, coat_d.g, coat_d.b, 0.8))
	p.stroke(Vector2(52, t0), Vector2(57, t0 + 30), 0.9, Color(coat_d.r, coat_d.g, coat_d.b, 0.5))
	# folds
	for f in [Vector2(30, t0 + 20), Vector2(35, t0 + 26), Vector2(31, t0 + 52), Vector2(42, t0 + 58)]:
		p.stroke(f, f + Vector2(1.5, 14.0), 1.4, Color(coat_d.r, coat_d.g, coat_d.b, 0.35))
	# buttons, belt, buckle, pocket
	for by in [26.0, 34.0, 42.0]:
		p.ellipse(54.5, t0 + by, 1.5, 1.5, Color("ffcd75"), 0.7)
	p.poly([Vector2(26, t0 + 44), Vector2(58, t0 + 44), Vector2(58, t0 + 49), Vector2(26, t0 + 49)], Color("1c1a24"), 0.4)
	p.poly([Vector2(49, t0 + 43), Vector2(55, t0 + 43), Vector2(55, t0 + 50), Vector2(49, t0 + 50)], Color("d8a040"), 0.6)
	p.poly([Vector2(51, t0 + 45), Vector2(53, t0 + 45), Vector2(53, t0 + 48), Vector2(51, t0 + 48)], Color("1c1a24"), 0.2)
	p.stroke(Vector2(34, t0 + 56), Vector2(44, t0 + 57), 1.0, Color(coat_d.r, coat_d.g, coat_d.b, 0.6))
	p.stroke(Vector2(24, t0 + 70), Vector2(60, t0 + 70), 1.6, Color(coat_d.r, coat_d.g, coat_d.b, 0.5))
	# neck and collar
	p.capsule(Vector2(44, 28 + oy), Vector2(44, 40 + oy), 4.8, 5.2, skin_d, 0.6)
	p.capsule(Vector2(37, t0 + 0.5), Vector2(51, t0 - 0.5), 3.2, 3.2, coat_l, 0.5)
	if pose == "read":
		p.poly([Vector2(49, 70 + oy), Vector2(68, 67 + oy), Vector2(69, 90 + oy), Vector2(51, 93 + oy)], Color("7a2a3a"), 0.5)
		p.poly([Vector2(50.5, 71.5 + oy), Vector2(67, 69 + oy), Vector2(67.5, 88 + oy), Vector2(52, 90.5 + oy)], Color("f2ecd8"), 0.4)
		p.stroke(Vector2(59, 70 + oy), Vector2(60, 89.5 + oy), 1.0, Color(0.5, 0.45, 0.35, 0.8))
		for ln in 6:
			p.stroke(Vector2(53, 74 + oy + ln * 2.8), Vector2(58, 73.4 + oy + ln * 2.8), 0.6, Color(0.3, 0.28, 0.25, 0.6))
			p.stroke(Vector2(61, 73.4 + oy + ln * 2.8), Vector2(66, 72.8 + oy + ln * 2.8), 0.6, Color(0.3, 0.28, 0.25, 0.6))
	# ---------------------------------------------------------------- near arm
	_arm(p, j["na"], sleeve, coat_l, skin, false)
	# ------------------------------------------------------------------- head
	var hy := oy + (2.0 if pose == "read" else 0.0)
	p.ellipse(33, 24 + hy, 8.5, 13.5, hair, 0.5)                       # hair at the back
	p.ellipse(41, 14 + hy, 14.5, 13.5, hair, 0.5)                      # hair mass
	p.ellipse(34, 21 + hy, 3.0, 4.0, skin_d, 0.6)                      # ear
	p.ellipse(45, 18 + hy, 12.5, 15.0, skin, 0.55)                     # face
	p.ellipse(45, 26 + hy, 10.0, 9.0, skin, 0.5)                       # jaw
	p.ellipse(51, 24 + hy, 4.5, 3.5, skin_l, 0.4, 0.55)                # cheek light
	p.ellipse(38, 21 + hy, 4.0, 8.0, skin_d, 0.5, 0.25)                # shadow side
	# fringe and sideburn
	p.ellipse(46, 6.5 + hy, 11.5, 5.5, hair, 0.5)
	p.capsule(Vector2(36, 8 + hy), Vector2(36.5, 22 + hy), 2.2, 1.6, hair, 0.5)
	p.capsule(Vector2(40, 4 + hy), Vector2(56, 8 + hy), 2.0, 1.2, hair_l, 0.4, 0.8)
	for s in 6:
		var sx := 30.0 + s * 4.4
		p.stroke(Vector2(sx, 5 + hy), Vector2(sx + 1.5, 12 + hy + (s % 2) * 2), 0.9, Color(hair_d.r, hair_d.g, hair_d.b, 0.5))
	# brow, eye, nose
	p.capsule(Vector2(46.5, 12.0 + hy), Vector2(55.5, 11.2 + hy), 1.3, 1.0, hair_d, 0.4)
	p.ellipse(51.5, 17.2 + hy, 3.6, 2.4, Color("f4f2ee"), 0.3)
	p.ellipse(52.6, 17.2 + hy, 2.1, 2.1, Color("4a6a9a"), 0.5)
	p.ellipse(52.9, 17.2 + hy, 1.1, 1.1, Color("10121c"), 0.1)
	p.ellipse(52.0, 16.5 + hy, 0.7, 0.6, Color("ffffff"), 0.0)
	p.stroke(Vector2(48.0, 15.4 + hy), Vector2(55.4, 15.4 + hy), 1.0, Color(0.1, 0.07, 0.08, 0.7))
	p.stroke(Vector2(49.0, 19.6 + hy), Vector2(54.4, 19.6 + hy), 0.6, Color(skin_d.r, skin_d.g, skin_d.b, 0.5))
	p.ellipse(57.5, 22 + hy, 2.4, 3.0, skin_l, 0.45)
	p.stroke(Vector2(55.5, 17 + hy), Vector2(57.0, 22.5 + hy), 0.8, Color(skin_d.r, skin_d.g, skin_d.b, 0.55))
	p.stroke(Vector2(56.0, 24.8 + hy), Vector2(59.0, 24.0 + hy), 0.9, Color(skin_d.r, skin_d.g, skin_d.b, 0.7))
	# mouth, or the beard that hides it
	var bl := beard_len(era)
	if bl <= 0.0:
		p.stroke(Vector2(49.5, 30.5 + hy), Vector2(56.0, 30.0 + hy), 1.0, Color(0.55, 0.28, 0.25, 0.9))
		p.ellipse(52, 27.5 + hy, 6, 1.4, skin_d, 0.4, 0.25)
	else:
		var bt := 27.0 + hy
		var pts: Array = [Vector2(34, 19 + hy), Vector2(37, 28 + hy), Vector2(38, bt + bl * 0.55), Vector2(43, bt + bl * 0.95), Vector2(47, bt + bl),
			Vector2(51, bt + bl * 0.9), Vector2(55, bt + bl * 0.5), Vector2(57.5, bt + 1), Vector2(58, 26 + hy), Vector2(47, 22 + hy)]
		p.poly(pts, bcol, 0.5)
		p.capsule(Vector2(50, 25.8 + hy), Vector2(59.5, 24.6 + hy), 2.0, 1.4, bcol, 0.5)
		for s in 7:
			var sx := 39.0 + s * 2.6
			p.stroke(Vector2(sx, bt - 1), Vector2(sx + 0.6, bt + bl * (0.45 + 0.4 * ((s * 37) % 10) / 10.0)), 0.7, Color(bcol.r * 0.7, bcol.g * 0.7, bcol.b * 0.72, 0.45))
		for s in 4:
			var sx2 := 41.0 + s * 3.4
			p.stroke(Vector2(sx2, bt + 2), Vector2(sx2 + 0.4, bt + bl * 0.6), 0.6, Color(1, 1, 1, 0.25))
	p.outline(Color(0.06, 0.05, 0.1, 0.95))
	var tx := p.texture()
	_cache[key] = tx
	return tx

static func hero(era: int) -> Dictionary:
	return {
		"idle": make(era, "idle"),
		"walk": [make(era, "walk_a"), make(era, "walk_b"), make(era, "walk_c"), make(era, "walk_d")],
		"sit": make(era, "sit"),
		"read": make(era, "read"),
	}
