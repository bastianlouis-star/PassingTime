extends SceneTree
# Checks the first room's workflow: 1st use = NEW, 2nd = note action appears, 3rd = exhaust
# action appears, exhausting removes the activity, and leaving needs time.
var game: Node
var frames := 0
var ok := true

func _initialize() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)

func _names(hid: String) -> Array:
	var out: Array = []
	for h in game.hotspots():
		if h["id"] == hid:
			for a in game.visible_acts(h):
				out.append(a["id"])
	return out

func _do(hid: String, aid: String) -> void:
	for h in game.hotspots():
		if h["id"] == hid:
			for a in h["acts"]:
				if a["id"] == aid:
					a["sec"] = 0.01
					game.start_action(h, a)
					game.run["prog"] = 1.0
					game.finish_action()
					return
	print("could not find ", aid)
	ok = false

func _expect(label: String, cond: bool) -> void:
	print(("ok   " if cond else "FAIL ") + label)
	if not cond:
		ok = false

func _process(_dt: float) -> bool:
	frames += 1
	if frames < 3:
		return false
	var sh := "shelf"
	_expect("fresh shelf shows only the novel (+ nothing else)", _names(sh) == ["read_novel"])
	_do(sh, "read_novel")
	_expect("after 1 read: still only the novel", _names(sh) == ["read_novel"])
	_do(sh, "read_novel")
	_expect("after 2 reads: search behind the books appears", _names(sh).has("search_shelf") and not _names(sh).has("read_all"))
	_do(sh, "read_novel")
	_expect("after 3 reads: 'read every book' appears", _names(sh).has("read_all"))
	_do(sh, "read_all")
	_expect("exhausted: the novel stays listed but is marked worn out", _names(sh).has("read_novel") and game.S["exhausted"].has("read_novel") and not _names(sh).has("read_all"))
	var shelf_h: Dictionary = {}
	for h in game.hotspots():
		if h["id"] == "shelf":
			shelf_h = h
	game.start_action(shelf_h, shelf_h["acts"][0])
	_expect("trying it again answers 'doesn't interest you'", game.run.is_empty() and game.msg == "It doesn't interest you anymore.")
	# leaving too early
	var door: Dictionary = {}
	for h in game.hotspots():
		if h["id"] == "door":
			door = h
	game.start_action(door, door["acts"][0])
	_expect("leaving early is refused with the message", game.run.is_empty() and game.msg == "The activities here can still pass time for a bit.")
	game.S["elapsed"] = float(game.S["elapsed"]) + 45.0 * Data.DAY
	_expect("after enough time the exit is ready", game.can_leave())
	# ---- the house
	game.S["era"] = 1
	game._enter_era(false)
	game.S["flags"]["found_notebook"] = true
	game.S["flags"].erase("read_every_book")
	_expect("writing a book is hidden until every book was read", not _names("desk").has("write"))

	game.S["flags"].erase("listened_all")
	_expect("piano is hidden until every record was heard", not _names("piano").has("piano"))
	game.S["flags"]["listened_all"] = true
	_expect("piano stays under its sheet until uncovered", _names("piano").has("uncover") and not _names("piano").has("piano"))
	_do("piano", "uncover")
	_expect("piano can be learned once uncovered", _names("piano").has("piano"))
	game.S["flags"]["read_every_book"] = true
	_expect("writing a book appears once the first room's books are exhausted", _names("desk").has("write"))
	_expect("only 'start writing' is offered at first", _names("desk").has("write") and not _names("desk").has("write2") and not _names("desk").has("write3"))
	_do("desk", "write")
	_expect("then 'continue writing'", _names("desk").has("write2") and not _names("desk").has("write3"))
	_do("desk", "write2")
	_expect("then 'finish your book'", _names("desk").has("write3"))
	_do("desk", "write3")
	_expect("the book is written after three sessions", game.has_flag("book_written"))
	_expect("write a book stays listed, worn out", _names("desk").has("write") and game.S["exhausted"].has("write"))
	_expect("piano starts with 'start learning'", _names("piano").has("piano") and not _names("piano").has("piano2"))
	_do("piano", "piano")
	_do("piano", "piano2")
	_do("piano", "piano3")
	_expect("the piano is learned after three sessions", game.has_flag("piano_learned"))
	_expect("piano stays listed, worn out", _names("piano").has("piano") and game.S["exhausted"].has("piano"))
	_do("apple", "wait_apples")
	_do("apple", "wait_apples")
	_expect("no apples after two waits", not game.has_flag("apples_grown"))
	_do("apple", "wait_apples")
	_expect("apples after three 30-day waits", game.has_flag("apples_grown"))
	_expect("stove has no cooking left", not _names("stove").has("cook") and not _names("stove").has("feast"))
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
	return true
