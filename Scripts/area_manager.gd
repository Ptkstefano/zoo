extends Node2D

class_name AreaManager

@export var available_fences : Array[fence_resource]
@onready var fence_menu = %FenceSelectionContainer
@export var ui_fence_element : PackedScene

@onready var area_layer = $"../TileMap/AreaLayer"

var selected_fence

#@export var fence_manager : FenceManager
@export var area_scene : PackedScene

func _ready() -> void:
	update_terrain_menu()

func update_terrain_menu():
	for child in fence_menu.get_children():
		child.queue_free()
		
	for fence_res in available_fences:
		var element = ui_fence_element.instantiate()
		element.fence_res = fence_res
		fence_menu.add_child(element)
		
	$"../UI".update_ui()
	
	selected_fence = available_fences[0]
	
	
func build_area(coordinates, fence_res):
	##Check if there is already area
	if fence_res:
		selected_fence = fence_res
	var current_area = null
	for coordinate in coordinates:
		if area_layer.get_cell_atlas_coords(coordinate) != Vector2i(-1,-1):
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
		#current_area.fence_manager = fence_manager
		add_child(current_area)
		current_area.add_cells(coordinates, selected_fence)

	##Expand existing area
	else:
		print('Expanding area')
		current_area.add_cells(coordinates, selected_fence)
		
	for coordinate in current_area.area_cells:
		area_layer.set_cell(coordinate, 0, Vector2i(0,0))

func get_existing_area(coordinate):
	for area in get_children():
		if area.area_cells.has(coordinate):
			return area
			
func remove_area(coordinates):
	## Find corresponding area 
	var working_areas = []
	for coordinate in coordinates:
		area_layer.set_cell(coordinate, -1, Vector2i(-1,-1))
		for area in get_children():
			if area.area_cells.has(coordinate):
				working_areas.append(area)
				area.remove_cells(coordinates)

func get_area_overlap(coordinates):
	var area_cells = area_layer.get_used_cells()
	for coordinate in coordinates:
		if coordinate in area_cells:
			return true
	return false
