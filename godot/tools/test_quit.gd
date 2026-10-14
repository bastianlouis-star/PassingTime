extends SceneTree
# Checks the leave-the-game flow: close request -> farewell screen with total real time -> quit after ~4 s.
var game: Node
var frames := 0
var t0 := 0.0
func _initialize() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
func _process(dt: float) -> bool:
	frames += 1
	if frames == 5:
		game.S["real"] = 3725.0
		print("text: ", game.fmt_real(3725.0), " | ", game.fmt_real(59.0), " | ", game.fmt_real(120.0))
		game._notification(Node.NOTIFICATION_WM_CLOSE_REQUEST)
		print("closing=", game.closing)
	if game.closing:
		t0 += dt
		if frames % 60 == 0:
			print("closing for ", snappedf(t0, 0.1), " s")
	return false
