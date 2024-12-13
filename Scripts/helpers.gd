extends Node

var terrain_layer

var thread : Thread

func _ready() -> void:
	thread = Thread.new()
	
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
	if tile_at_position.x > GameManager.playable_area_size * 0.5:
		return false
	if tile_at_position.x < -GameManager.playable_area_size * 0.5:
		return false
	if tile_at_position.y > GameManager.playable_area_size * 0.5:
		return false
	if tile_at_position.y < -GameManager.playable_area_size * 0.5:
		return false
	return true

func generate_random_position_at_distance_from_origin(origin : Vector2, distance : float):
	var random_angle: float = randf() * TAU # TAU is 2π

	var x: float = cos(random_angle) * distance
	var y: float = sin(random_angle) * distance

	return Vector2(x, y) + origin

func money_text(value) -> String:
	return "$" + str(value)

func get_cell_quadrant(global_coordinate : Vector2):
	var cell = TileMapRef.local_to_map(global_coordinate)
	var cell_center = TileMapRef.map_to_local(cell)
	var center_offset = cell_center - global_coordinate
	
	if center_offset.x < 0:
		if center_offset.y < 0:
			## (-,-)
			return 0
		else:
			## (-,+)
			return 3
	else:
		if center_offset.y > 0:
			## (+, +)
			return 2
		else:
			## (+, -)
			return 1
			
		
