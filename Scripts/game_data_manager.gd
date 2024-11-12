extends Node2D

class_name EnclosureManager

@export var available_enclosures : Array[fence_resource]
@onready var enclosure_menu = %EnclosureSelectionContainer
@export var ui_enclosure_element : PackedScene

@onready var enclosure_layer = $"../../TileMap/EnclosureLayer"

var selected_fence

#@export var enclosure_manager : EnclosureManager
@export var enclosure_scene : PackedScene

func _ready() -> void:
	update_terrain_menu()
	SignalBus.vegetation_placed.connect(check_for_vegetation_update)
	SignalBus.load_enclosure.connect(build_enclosure)



func update_terrain_menu():
	for child in enclosure_menu.get_children():
		child.queue_free()
		
	for enclosure_res in available_enclosures:
		var element = ui_enclosure_element.instantiate()
		element.enclosure_res = enclosure_res
		enclosure_menu.add_child(element)
		
	$"../../UI".update_ui()
	
	selected_fence = available_enclosures[0]
	
	
func build_enclosure(id, coordinates, entrance_cell, fence_res):
	##Check if there is already enclosure
	if fence_res:
		selected_fence = fence_res
	var current_enclosure = null
	for coordinate in coordinates:
		if enclosure_layer.get_cell_atlas_coords(coordinate) != Vector2i(-1,-1):
			var found_enclosure = get_enclosure_by_cell(coordinate)
			if found_enclosure:
				if !current_enclosure:
					#print('Found enclosure')
					current_enclosure = found_enclosure
				elif current_enclosure != found_enclosure:
					#print('Not allowed to merge two enclosures')
					return

	##Create new enclosure
	if !current_enclosure:
		#print('create')
		current_enclosure = enclosure_scene.instantiate()
		add_child(current_enclosure)
		if id == null:
			current_enclosure.set_id(ZooManager.generate_enclosure_id())
		else:
			current_enclosure.set_id(id)
		current_enclosure.fence_res = selected_fence
		current_enclosure.create_sibling_enclosure.connect(build_enclosure)
		current_enclosure.add_cells(coordinates, selected_fence)
		print('a')
		SignalBus.save_new_enclosure.emit(current_enclosure.id, coordinates, fence_res.get_path())

	##Expand existing enclosure
	else:
		current_enclosure.fence_res = selected_fence
		current_enclosure.add_cells(coordinates, selected_fence)
		SignalBus.save_update_enclosure.emit(current_enclosure.id, current_enclosure.enclosure_cells, current_enclosure.entrance_door_cell, current_enclosure.fence_res.get_path())
		
	for coordinate in current_enclosure.enclosure_cells:
		enclosure_layer.set_cell(coordinate, 0, Vector2i(0,0))
		
	if entrance_cell:
		current_enclosure.place_entrance(entrance_cell)
	#SignalBus.save_game.emit()

func return_enclosures():
	return get_children()

func get_existing_enclosures(coordinates):
	var enclosures = []
	for child in get_children():
		for coordinate in coordinates:
			if child.enclosure_cells.has(coordinate):
				if child not in enclosures:
					enclosures.append(child)
	return enclosures
	
func get_enclosure_by_cell(cell : Vector2i):
	for child in get_children():
		if child.enclosure_cells.has(cell):
			return child
				
	return null
	
func check_for_vegetation_update(vegetation_position):
	var vegetation_cell = TileMapRef.local_to_map(vegetation_position)
	var enclosure = get_enclosure_by_cell(vegetation_cell)
	if enclosure:
		enclosure.call_deferred("calculate_enclosure_stats")
	
	
func remove_enclosure_cells(coordinates):
	## TODO - Find corresponding enclosure REMOVE FROM GAMEMANAGER
	var working_enclosures = []
	for coordinate in coordinates:
		enclosure_layer.set_cell(coordinate, -1, Vector2i(-1,-1))
		for enclosure in get_children():
			if enclosure.enclosure_cells.has(coordinate):
				working_enclosures.append(enclosure)
				enclosure.remove_cells(coordinates)
				SignalBus.save_update_enclosure.emit(enclosure.id, enclosure.enclosure_cells, enclosure.entrance_door_cell, enclosure.fence_res.get_path())
	
func place_entrance(coordinates):
	var cell = TileMapRef.local_to_map(coordinates)
	var enclosure = get_enclosure_by_cell(cell)
	## Try for adjacent cells in case player doesn't tap precisely
	if !enclosure:
		for adjancent_cell in Helpers.get_adjacent(cell):
			cell = adjancent_cell
			enclosure = get_enclosure_by_cell(adjancent_cell)
			if enclosure:
				break
				
	if enclosure:
		enclosure.place_entrance(cell)
		SignalBus.save_update_enclosure.emit(enclosure.id, enclosure.enclosure_cells, enclosure.entrance_door_cell, enclosure.fence_res.get_path())
	

func get_enclosure_overlap(cells):
	var enclosure_cells = enclosure_layer.get_used_cells()
	for cell in cells:
		if cell in enclosure_cells:
			return true
	return false
