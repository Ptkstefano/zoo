extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_adjacent(coordinate) -> Array:
	var e = Vector2i(coordinate.x + 1, coordinate.y)
	var s = Vector2i(coordinate.x, coordinate.y + 1)
	var w = Vector2i(coordinate.x - 1, coordinate.y)
	var n = Vector2i(coordinate.x, coordinate.y - 1)
	
	return [e, s, w, n]
