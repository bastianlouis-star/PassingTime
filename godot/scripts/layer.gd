extends Node2D
# The HUD layer owned by Main (native-resolution vector text and UI).

var main: Node
var kind := 1

func _draw() -> void:
	if main != null:
		main.draw_hud(self)
