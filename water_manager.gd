extends Node2D

@export var lake_scene : PackedScene

var water_cells : Array[Vector2i]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_water_body(points):
	if points.size() < 5:
		return
		
	for point in points:
		if TileMapRef.local_to_map(point) in $"../../PathManager".path_coordinates:
			return
	for point in points:
		if TileMapRef.local_to_map(point) in water_cells:
			return
		
	## Adds points to soften hard edges
	var smooth_points = smooth_lines(points)
		
	## Ensures line loops back on itself
	#smooth_points.append(smooth_points[0])
	
	## Pixelizes line
	var shoreline_points = pixelate_lines(smooth_points)
	
	## To ensure polygon is not self intersecting, creates a copy of the array without the final element
	#var comparison_array = shoreline_points.duplicate()
	#comparison_array.pop_back()
	if is_polygon_self_intersecting(smooth_points):
		return
	
	var new_lake = lake_scene.instantiate()
	new_lake.line_points = points
	new_lake.shoreline_points = shoreline_points
	var lake_cells = []
	for point in points:
		var point_cell = TileMapRef.local_to_map(point)
		if point_cell not in lake_cells:
			lake_cells.append(point_cell)
	for cell in lake_cells:
		$"../../TileMap/WaterCoverageLayer".set_cell(cell, 0, Vector2i(0,0))
		if cell not in water_cells:
			water_cells.append(cell)
	new_lake.cells = lake_cells
	new_lake.lake_removed.connect(on_lake_removed)
	add_child(new_lake)
	TileMapRef.update_enclosures(lake_cells)

func on_lake_removed(cells):
	for cell in cells:
		water_cells.erase(cell)

func get_water_availability(cells):
	for cell in cells:
		if cell in water_cells:
			return true
			
	return false

func draw_placeholder(points):
	var smooth_points = smooth_lines(points)
	$PlaceholderLine.points = smooth_points
	for point in points:
		if TileMapRef.local_to_map(point) in $"../../PathManager".path_coordinates:
			$PlaceholderLine.default_color = Color('#f04644')
			return
	for point in points:
		if TileMapRef.local_to_map(point) in water_cells:
			$PlaceholderLine.default_color = Color('#f04644')
			return
	if is_polygon_self_intersecting(smooth_points):
		$PlaceholderLine.default_color = Color('#f04644')
		return
	else:
		$PlaceholderLine.default_color = Color('#4874f4')

func clear_placeholder():
	$PlaceholderLine.points = []

func pixelate_lines(points):
	points.append(points[0])
	var shoreline_points = []
	shoreline_points.append(points[0])
	var current_point = shoreline_points[0]
	for i in range(1, points.size()):  # Start from 1 to avoid repeating the first point
		while current_point.distance_to(points[i]) > 4:
			var x_diff = points[i].x - current_point.x
			var y_diff = points[i].y - current_point.y
			var next_point = current_point
			
			if abs(x_diff) > abs(y_diff):
				next_point = Vector2(next_point.x + sign(x_diff) * 2, current_point.y)
			else:
				next_point = Vector2(current_point.x, next_point.y + sign(y_diff) * 1)
			
			shoreline_points.append(next_point)
			current_point = next_point
		
	shoreline_points.append(points[0])  # Connect back to the start
	return shoreline_points


func smooth_lines(points):
	var new_array = []
	var current_vector
	var previous_vector
	var next_vector
	var new_vector1
	var new_vector2
	for i in points.size():
		if i == 1:
			current_vector = points[i-1]
			previous_vector = points[points.size()-1]
			next_vector = points[i]
		elif i == points.size() - 1:
			continue
			current_vector = points[i-1]
			previous_vector = points[i-2]
			next_vector = points[0]
		else:
			current_vector = points[i-1]
			previous_vector = points[i-2]
			next_vector = points[i]
			
			
		new_vector1 = current_vector.move_toward(previous_vector, 10)
		new_vector2 = current_vector.move_toward(next_vector, 10)
		
		new_array.append(new_vector1)
		new_array.append(new_vector2)
	return new_array


func is_polygon_self_intersecting(points: Array) -> bool:
	var num_points = points.size() - 1

	# Loop through each pair of edges
	for i in range(num_points):
		var a1 = points[i]
		var a2 = points[(i + 1) % num_points]

		for j in range(i + 2, num_points):
			# Skip adjacent edges, they share a point and can't intersect
			if j == (i + num_points - 1) % num_points:
				continue

			var b1 = points[j]
			var b2 = points[(j + 1) % num_points]

			if lines_intersect(a1, a2, b1, b2):
				return true
	return false


# Helper function to check if two line segments (a1->a2 and b1->b2) intersect
func lines_intersect(a1: Vector2, a2: Vector2, b1: Vector2, b2: Vector2) -> bool:
	var s1 = a2 - a1
	var s2 = b2 - b1

	var s = (-s1.y * (a1.x - b1.x) + s1.x * (a1.y - b1.y)) / (-s2.x * s1.y + s1.x * s2.y)
	var t = ( s2.x * (a1.y - b1.y) - s2.y * (a1.x - b1.x)) / (-s2.x * s1.y + s1.x * s2.y)

	return (s >= 0 and s <= 1 and t >= 0 and t <= 1)
