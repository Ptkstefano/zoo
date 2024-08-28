extends Node2D

class_name PathManager

@onready var path_layer = $"../TileMap/PathLayer"
var path_coordinates = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	path_coordinates = path_layer.get_used_cells()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func build_path(coordinates, dir):
	## Builds a straight path and lists neighbor paths
	var all_neighbors = []
	for coordinate in coordinates:
		if coordinate not in path_coordinates:
			path_coordinates.append(coordinate)
		if dir == 'x':
			path_layer.set_cell(coordinate, 0, Vector2(0,0))
		if dir == 'y':
			path_layer.set_cell(coordinate, 0, Vector2(1,0))
		var neighbors = path_layer.get_surrounding_cells(coordinate)
		for neighbor in neighbors:
			if path_layer.get_cell_atlas_coords(neighbor) != Vector2i(-1,-1):
				if neighbor not in all_neighbors:
					all_neighbors.append(neighbor)
		## Adds intersections to built paths
		build_intersections(coordinate)
	for neighbor in all_neighbors:
		## Adds instersections to neighbors of built paths
		build_intersections(neighbor)
	
func remove_path(coordinates):
	var all_neighbors = []
	for coordinate in coordinates:
		path_layer.set_cell(coordinate, 0, Vector2(-1,-1))
		if coordinate in path_coordinates:
			path_coordinates.erase(coordinate)
	for coordinate in coordinates:
		var neighbors = path_layer.get_surrounding_cells(coordinate)
		for neighbor in neighbors:
			if path_layer.get_cell_atlas_coords(neighbor) != Vector2i(-1,-1):
				if neighbor not in all_neighbors:
					all_neighbors.append(neighbor)
	for neighbor in all_neighbors:
		## Adds instersections to neighbors of built paths
		build_intersections(neighbor)


func build_intersections(coordinate):
	var found_paths = []
	var neighbors = path_layer.get_surrounding_cells(coordinate)
	for neighbor in neighbors:
		if path_layer.get_cell_atlas_coords(neighbor) != Vector2i(-1,-1):
			found_paths.append(1)
		else:
			found_paths.append(0)
	if found_paths[0] or found_paths[2]:
		path_layer.set_cell(coordinate, 0, Vector2(0,0))
	if found_paths[1] or found_paths[3]:
		path_layer.set_cell(coordinate, 0, Vector2(1,0))
	if found_paths == [1,1,0,0]:
		path_layer.set_cell(coordinate, 0, Vector2(3,0))
	elif found_paths == [1,0,0,1]:
		path_layer.set_cell(coordinate, 0, Vector2(4,0))
	elif found_paths == [0,1,1,0]:
		path_layer.set_cell(coordinate, 0, Vector2(5,0))
	elif found_paths == [0,0,1,1]:
		path_layer.set_cell(coordinate, 0, Vector2(6,0))
	## Intersections
	elif found_paths == [1,1,1,0]:
		path_layer.set_cell(coordinate, 0, Vector2(7,0))
	elif found_paths == [1,0,1,1]:
		path_layer.set_cell(coordinate, 0, Vector2(8,0))
	elif found_paths == [0,1,1,1]:
		path_layer.set_cell(coordinate, 0, Vector2(9,0))
	elif found_paths == [1,1,0,1]:
		path_layer.set_cell(coordinate, 0, Vector2(10,0))
	elif found_paths == [1,1,1,1]:
		path_layer.set_cell(coordinate, 0, Vector2(2,0))

#TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE
func generate_peep_destination():
	var random_cell = path_coordinates.pick_random()
	var random_position = path_layer.map_to_local(random_cell)
	return random_position
