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
			
		
func get_building_cells(building_size, start_tile, direction):
	var cells : Array[Vector2i] = []
	if direction in [0,2]:
		for x in range(abs(building_size.x)):
			for y in range(abs(building_size.y)):
				var new_coordinate = Vector2i(start_tile.x - x, start_tile.y - y)
				cells.append(new_coordinate)
	if direction in [1,3]:
		for x in range(abs(building_size.x)):
			for y in range(abs(building_size.y)):
				var new_coordinate = Vector2i(start_tile.x - y, start_tile.y - x)
				cells.append(new_coordinate)
	return cells

func format_months_to_years_and_months(months: int) -> String:
	var years = months / 12
	var remaining_months = months % 12
	var result = ""

	if years > 0:
		result += str(years) + " year" 
		if years > 1:
			result += "s"
	if years > 0 and remaining_months > 0:
		result += " and "
	if remaining_months > 0:
		result += str(remaining_months) + " month"
		if remaining_months > 1:
			result += "s"

	return result


func get_utility_score(perceived_value, current_price, product_level, level_difference):
	var item_utility_score = (perceived_value / current_price) + (0.05 * (product_level - 1)) * randf_range(0.8, 1.2)
	if level_difference == 0:
		## Peeps prefer items of their minimum level, but will still choose better items if they deem it worth it
		item_utility_score *= 1.20
	else:
		## However, items of different product level than desired get a reduced desirability the greater the difference
		var level_diff = abs(level_difference) * 0.2
		item_utility_score *= (1 - level_diff)
	return item_utility_score
