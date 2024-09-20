extends Node

var terrain_layer

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func get_adjacent(coordinate) -> Array:
	var e = Vector2i(coordinate.x + 1, coordinate.y)
	var s = Vector2i(coordinate.x, coordinate.y + 1)
	var w = Vector2i(coordinate.x - 1, coordinate.y)
	var n = Vector2i(coordinate.x, coordinate.y - 1)
	
	return [e, s, w, n]

func get_current_tile_z_index(global_position):
	var coordinate = TileMapRef.local_to_map(global_position)
	return ((coordinate.x + coordinate.y) * 3)

func get_global_pos_of_cell(coordinate):
	return TileMapRef.map_to_local(coordinate)

func is_valid_cell(position):
	var tile_at_position = TileMapRef.local_to_map(position)
	if tile_at_position.x > DataManager.playable_area_size * 0.5:
		return false
	if tile_at_position.x < -DataManager.playable_area_size * 0.5:
		return false
	if tile_at_position.y > DataManager.playable_area_size * 0.5:
		return false
	if tile_at_position.y < -DataManager.playable_area_size * 0.5:
		return false
	return true

func generate_random_position_at_distance_from_origin(origin : Vector2, distance : float):
	var random_angle: float = randf() * TAU # TAU is 2π

	var x: float = cos(random_angle) * distance
	var y: float = sin(random_angle) * distance

	return Vector2(x, y) + origin
