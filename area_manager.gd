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
		remove_fence(current_area.area_cells)
		current_area.add_cells(coordinates)
		
	for coordinate in current_area.area_cells:
		total_area_layer.set_cell(coordinate, 0, Vector2i(0,0))
	build_fence(current_area)
	
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
				remove_fence(area.area_cells)
				area.remove_cells(coordinates)
				
	for working_area in working_areas:
		build_fence(working_area)

func build_fence(area_instance):
	for coordinate in area_instance.area_cells:
		var east_cell = Vector2i(coordinate.x + 1, coordinate.y)
		var south_cell = Vector2i(coordinate.x, coordinate.y + 1)
		var west_cell= Vector2i(coordinate.x - 1, coordinate.y)
		var north_cell= Vector2i(coordinate.x, coordinate.y - 1)
		
		if area_instance.area_tilemap.get_cell_atlas_coords(east_cell) == Vector2i(-1,-1):
			$"../TileMap/FenceLayer/FenceE".set_cell(coordinate, 0, Vector2i(0,0))
		if area_instance.area_tilemap.get_cell_atlas_coords(south_cell) == Vector2i(-1,-1):
			$"../TileMap/FenceLayer/FenceS".set_cell(coordinate, 0, Vector2i(1,0))
		if area_instance.area_tilemap.get_cell_atlas_coords(west_cell) == Vector2i(-1,-1):
			$"../TileMap/FenceLayer/FenceW".set_cell(coordinate, 0, Vector2i(2,0))
		if area_instance.area_tilemap.get_cell_atlas_coords(north_cell) == Vector2i(-1,-1):
			$"../TileMap/FenceLayer/FenceN".set_cell(coordinate, 0, Vector2i(3,0))

func remove_fence(coordinates):
	for fence_layer in $"../TileMap/FenceLayer".get_children():
		for coordinate in coordinates:
			if fence_layer.get_cell_atlas_coords(coordinate) != Vector2i(-1,-1):
				fence_layer.set_cell(coordinate, -1, Vector2i(-1,-1))
