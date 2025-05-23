extends Node2D

class_name EnclosureManager

@export var available_enclosures : Array[fence_resource]
@export var ui_enclosure_element : PackedScene

@onready var enclosure_layer = $"../../TileMap/EnclosureLayer"

var selected_fence

#@export var enclosure_manager : EnclosureManager
@export var enclosure_scene : PackedScene

func _ready() -> void:
	SignalBus.vegetation_placed.connect(check_for_vegetation_update)
	SignalBus.path_layer_updated.connect(update_enclosures_sight_lines)

	
	
func build_enclosure(id, cells, entrance_cell, fence_res, is_enclosure_in_work_queue):
	##Check if there is already enclosure
	if fence_res:
		selected_fence = fence_res

	var enclosures_in_area = get_existing_enclosures_in_area(cells)

	##Create new enclosure
	if enclosures_in_area.size() == 0:
		var new_enclosure = enclosure_scene.instantiate()
		add_child(new_enclosure)
		if id == null:
			new_enclosure.set_id(ZooManager.generate_enclosure_id())
		else:
			new_enclosure.set_id(id)
		new_enclosure.fence_res = selected_fence
		new_enclosure.create_sibling_enclosure.connect(build_enclosure)
		new_enclosure.add_cells(cells, selected_fence)
		## Load data
		if entrance_cell:
			new_enclosure.place_entrance(entrance_cell)
		if is_enclosure_in_work_queue:
			new_enclosure.add_to_work_queue()
		for coordinate in new_enclosure.enclosure_cells:
			enclosure_layer.set_cell(coordinate, 0, Vector2i(0,0))

	##Expand existing enclosure
	elif enclosures_in_area.size() == 1:
		var current_enclosure = enclosures_in_area.front()
		#current_enclosure.fence_res = selected_fence
		if current_enclosure.fence_res != selected_fence:
			print('different fence')
			var popup_text = tr('POPUP_CONFIRM_ENCLOSURE_FENCE_CHANGE')
			SignalBus.open_confirmation_popup.emit(update_fence_callable, popup_text, {'resource': selected_fence, 'enclosure': current_enclosure})
		current_enclosure.add_cells(cells, selected_fence)
		for coordinate in current_enclosure.enclosure_cells:
			enclosure_layer.set_cell(coordinate, 0, Vector2i(0,0))
			
	else:
		return
		
func update_fence_callable(data):
	data['enclosure'].update_fence(data['resource'])
	
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
	
func check_for_vegetation_update(vegetation_position):
	var vegetation_cell = TileMapRef.local_to_map(vegetation_position)
	var enclosure = get_enclosure_by_cell(vegetation_cell)
	if enclosure:
		enclosure.call_deferred("calculate_enclosure_stats")
	
	
func remove_enclosure_cells(coordinates):
	var working_enclosures = []
	for coordinate in coordinates:
		enclosure_layer.set_cell(coordinate, -1, Vector2i(-1,-1))
		
		for enclosure in get_children():
			if enclosure.enclosure_cells.has(coordinate):
				working_enclosures.append(enclosure)
				enclosure.remove_cells(coordinates)
	
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
	

func get_enclosure_overlap(cells):
	var enclosure_cells = enclosure_layer.get_used_cells()
	for cell in cells:
		if cell in enclosure_cells:
			return true
	return false

func restore_enclosure_feed(enclosure_id, feed_data):
	for child in get_children():
		if child.id == enclosure_id:
			child.restore_animal_feed(feed_data)

func get_existing_enclosures_in_area(cells):
	var found_enclosures = []
	for cell in cells:
		if enclosure_layer.get_cell_atlas_coords(cell) != Vector2i(-1,-1):
			var found_enclosure = get_enclosure_by_cell(cell)
			if found_enclosure not in found_enclosures:
				if found_enclosure:
					found_enclosures.append(found_enclosure)
				
	return found_enclosures

func update_enclosures_sight_lines(new_path_cells):
	var adjacent_cells_to_new_paths = []
	for cell in new_path_cells:
		var adjacent_cells = Helpers.get_adjacent(cell)
		for adjacent_cell in adjacent_cells:
			if adjacent_cell not in new_path_cells:
				if adjacent_cell not in adjacent_cells_to_new_paths:
					adjacent_cells_to_new_paths.append(adjacent_cell)
				
	var iterated_enclosures = []
	for cell in adjacent_cells_to_new_paths:
		var found_enclosure = get_enclosure_by_cell(cell)
		if found_enclosure:
			if found_enclosure not in iterated_enclosures:
				found_enclosure.generate_sight_cells()
				iterated_enclosures.append(found_enclosure)
