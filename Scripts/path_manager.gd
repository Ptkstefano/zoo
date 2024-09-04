extends Node2D

class_name PathManager

@export var available_paths : Array[path_resource]
@onready var path_menu = %PathSelectionContainer
@export var ui_element : PackedScene

@onready var path_layer = $"../TileMap/PathLayer"
var path_coordinates = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	path_coordinates = path_layer.get_used_cells()
	update_path_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_path_menu():
	for child in path_menu.get_children():
		child.queue_free()
		
	for path_res in available_paths:
		var element = ui_element.instantiate()
		element.path_res = path_res
		path_menu.add_child(element)
		
	$"../UI".update_ui()
	

func build_path(coordinates, dir, path_res):
	## Builds a straight path and lists neighbor paths
	var all_neighbors = []
	for coordinate in coordinates:
		if coordinate not in path_coordinates:
			path_coordinates.append(coordinate)
		if dir == 'x':
			path_layer.set_cell(coordinate, 0, Vector2(0,path_res.atlas_y))
		if dir == 'y':
			path_layer.set_cell(coordinate, 0, Vector2(1,path_res.atlas_y))
		var neighbors = path_layer.get_surrounding_cells(coordinate)
		for neighbor in neighbors:
			if path_layer.get_cell_atlas_coords(neighbor) != Vector2i(-1,-1):
				if neighbor not in all_neighbors:
					all_neighbors.append(neighbor)
		## Adds intersections to built paths
		build_intersections(coordinate, path_res)
	for neighbor in all_neighbors:
		## Adds instersections to neighbors of built paths
		build_intersections(neighbor, null)
	
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
		build_intersections(neighbor, null)


func build_intersections(coordinate, path_res):
	var path_y = null
	if path_res:
		path_y = path_res.atlas_y
	var found_paths = []
	var neighbors = path_layer.get_surrounding_cells(coordinate)
	for neighbor in neighbors:
		if path_layer.get_cell_atlas_coords(neighbor) != Vector2i(-1,-1):
			found_paths.append(1)
		else:
			found_paths.append(0)
	if found_paths[0] or found_paths[2]:
		path_layer.set_cell(coordinate, 0, Vector2(0,path_layer.get_cell_atlas_coords(coordinate).y))
	if found_paths[1] or found_paths[3]:
		path_layer.set_cell(coordinate, 0, Vector2(1,path_layer.get_cell_atlas_coords(coordinate).y))
	if found_paths == [1,1,0,0]:
		path_layer.set_cell(coordinate, 0, Vector2(3,path_layer.get_cell_atlas_coords(coordinate).y))
	elif found_paths == [1,0,0,1]:
		path_layer.set_cell(coordinate, 0, Vector2(4,path_layer.get_cell_atlas_coords(coordinate).y))
	elif found_paths == [0,1,1,0]:
		path_layer.set_cell(coordinate, 0, Vector2(5,path_layer.get_cell_atlas_coords(coordinate).y))
	elif found_paths == [0,0,1,1]:
		path_layer.set_cell(coordinate, 0, Vector2(6,path_layer.get_cell_atlas_coords(coordinate).y))
	## Intersections
	elif found_paths == [1,1,1,0]:
		path_layer.set_cell(coordinate, 0, Vector2(7,path_layer.get_cell_atlas_coords(coordinate).y))
	elif found_paths == [1,0,1,1]:
		path_layer.set_cell(coordinate, 0, Vector2(8,path_layer.get_cell_atlas_coords(coordinate).y))
	elif found_paths == [0,1,1,1]:
		path_layer.set_cell(coordinate, 0, Vector2(9,path_layer.get_cell_atlas_coords(coordinate).y))
	elif found_paths == [1,1,0,1]:
		path_layer.set_cell(coordinate, 0, Vector2(10,path_layer.get_cell_atlas_coords(coordinate).y))
	elif found_paths == [1,1,1,1]:
		path_layer.set_cell(coordinate, 0, Vector2(2,path_layer.get_cell_atlas_coords(coordinate).y))

#TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE
func generate_peep_destination():
	var random_cell = path_coordinates.pick_random()
	var random_position = path_layer.map_to_local(random_cell)
	return random_position

func get_fence_overlap(coordinates):
	var path_cells = path_layer.get_used_cells()
	for coordinate in coordinates:
		if coordinate in path_cells:
			return true
	return false
