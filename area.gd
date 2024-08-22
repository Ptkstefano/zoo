extends Node

var area_cells = []
@onready var area_tilemap = $AreaTiles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_cells(coordinates):
	for coordinate in coordinates:
		$AreaTiles.set_cell(coordinate, 0, Vector2i(0,0))
		if !area_cells.has(coordinate):
			area_cells.append(coordinate)
			
func remove_cells(coordinates):
	for coordinate in coordinates:
		$AreaTiles.set_cell(coordinate, -1, Vector2i(-1,-1))
		if area_cells.has(coordinate):
			area_cells.erase(coordinate)
	detect_continuity()

func detect_continuity():
	## Figures out
	if area_cells.size() == 0:
		return
	var iterated_coordinates = []
	var n_areas = 0
	while(iterated_coordinates.size() != area_cells.size()):
		var starting_cell = find_first_coordinate_not_matching(iterated_coordinates)
		n_areas += 1
		for coordinate in get_isolated_area(area_cells[starting_cell]):
			if !iterated_coordinates.has(coordinate):
				iterated_coordinates.append(coordinate)
	print(n_areas)
	## TODO - Currently we get the number of separated areas resulted from the splitting of this area
	## TODO - Get the area cells of each separated area an create sibling
		
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
			
