extends Node

class_name area

@onready var area_scene = preload("res://area.tscn")

var area_cells = []
var fence_cells = []

@onready var area_tilemap = $AreaTiles
@onready var fence_layer = $FenceLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_animal_destination():
	var random_cell = area_cells.pick_random()
	var random_position = Vector2(random_cell.x*64, random_cell.y*32)
	return random_position
	

func add_cells(coordinates):
	for coordinate in coordinates:
		$AreaTiles.set_cell(coordinate, 0, Vector2i(0,0))
		if !area_cells.has(coordinate):
			area_cells.append(coordinate)
	build_fence()
			
func remove_cells(coordinates):
	for coordinate in coordinates:
		$AreaTiles.set_cell(coordinate, -1, Vector2i(-1,-1))
		if area_cells.has(coordinate):
			area_cells.erase(coordinate)
	detect_continuity()
	build_fence()
	
func detect_continuity():
	## Figures out if current area was broken into multiple areas and instantiates newly created areas as siblings
	if area_cells.size() == 0:
		return
	var iterated_coordinates = []
	var existing_areas = []
	var n_areas = 0
	
	
	while(iterated_coordinates.size() != area_cells.size()):
		var starting_cell = find_first_coordinate_not_matching(iterated_coordinates)
		n_areas += 1
		var current_area = []
		for coordinate in get_isolated_area(area_cells[starting_cell]):
			if !iterated_coordinates.has(coordinate):
				current_area.append(coordinate)
				iterated_coordinates.append(coordinate)
		existing_areas.append(current_area)
	
	if existing_areas.size() > 1:
		area_cells = existing_areas[0]
		for i in existing_areas.size():
			if i == 0:
				continue
			create_sibling_area(existing_areas[i])
		
func get_isolated_area(starting_coordinate):
	var current_iterated_coordinates = [starting_coordinate]
	for coordinate in current_iterated_coordinates:
		var adjacent_cells = Helpers.get_adjacent(coordinate)
		for adjacent_cell in adjacent_cells:
			if area_cells.has(adjacent_cell):
				if !current_iterated_coordinates.has(adjacent_cell):
					current_iterated_coordinates.append(adjacent_cell)
	return current_iterated_coordinates
					
		
func find_first_coordinate_not_matching(iterated_coordinates):
	for coordinate in area_cells:
		if coordinate not in iterated_coordinates:
			return area_cells.find(coordinate)
			
func create_sibling_area(cells):
	var sibling = area_scene.instantiate()
	add_sibling(sibling)
	remove_cells(cells)
	sibling.add_cells(cells)
	
func build_fence():
	remove_fence()
	for coordinate in area_cells:
		var east_cell = Vector2i(coordinate.x + 1, coordinate.y)
		var south_cell = Vector2i(coordinate.x, coordinate.y + 1)
		var west_cell= Vector2i(coordinate.x - 1, coordinate.y)
		var north_cell= Vector2i(coordinate.x, coordinate.y - 1)
		
		if area_tilemap.get_cell_atlas_coords(east_cell) == Vector2i(-1,-1):
			$FenceLayer/E.set_cell(coordinate, 0, Vector2i(0,0))
			fence_cells.append(coordinate)
		if area_tilemap.get_cell_atlas_coords(south_cell) == Vector2i(-1,-1):
			$FenceLayer/S.set_cell(coordinate, 0, Vector2i(1,0))
			fence_cells.append(coordinate)
		if area_tilemap.get_cell_atlas_coords(west_cell) == Vector2i(-1,-1):
			$FenceLayer/W.set_cell(coordinate, 0, Vector2i(2,0))
			fence_cells.append(coordinate)
		if area_tilemap.get_cell_atlas_coords(north_cell) == Vector2i(-1,-1):
			$FenceLayer/N.set_cell(coordinate, 0, Vector2i(3,0))
			fence_cells.append(coordinate)

func remove_fence():
	## TODO - SEPARATE fence_cells BY CARDINAL DIRECTION
	for fence_layer in $FenceLayer.get_children():
		for coordinate in fence_cells:
			if fence_layer.get_cell_atlas_coords(coordinate) != Vector2i(-1,-1):
				fence_layer.set_cell(coordinate, -1, Vector2i(-1,-1))
	fence_cells.clear()
