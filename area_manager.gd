extends Node2D

@onready var total_area_layer = $"../TileMap/AreaLayer"
@export var area_scene : PackedScene


func build_area(coordinates):
	##Check if there is already area
	var current_area = null
	for coordinate in coordinates:
		if total_area_layer.get_cell_atlas_coords(coordinate) != Vector2i(-1,-1):
			var found_area = get_existing_area(coordinate)
			if found_area:
				if !current_area:
					current_area = found_area
				elif current_area != found_area:
					print('Not allowed to merge two areas')
					return

	##Create new area
	if !current_area:
		print('Creating area')
		current_area = area_scene.instantiate()
		add_child(current_area)
		current_area.add_cells(coordinates)
	##Expand existing area
	else:
		print('Expanding area')
		current_area.add_cells(coordinates)
		
	for coordinate in current_area.area_cells:
		total_area_layer.set_cell(coordinate, 0, Vector2i(0,0))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_existing_area(coordinate):
	for area in get_children():
		if area.area_cells.has(coordinate):
			return area
			
func remove_area(coordinates):
	## Find corresponding area 
	var working_areas = []
	for coordinate in coordinates:
		total_area_layer.set_cell(coordinate, -1, Vector2i(-1,-1))
		for area in get_children():
			if area.area_cells.has(coordinate):
				working_areas.append(area)
				area.remove_cells(coordinates)
