extends Node2D
class_name FixtureManager

@export var available_fixtures : Array[fixture_resource]

@export var bench_scene : PackedScene
@export var side_fixture : PackedScene

@export var ui_scenery_element : PackedScene

@export var pathLayer : TileMapLayer

var used_cells = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_selection_menu()
	SignalBus.path_erased.connect(remove_fixture_from_path)
	SignalBus.path_changed.connect(replace_fixture)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_selection_menu():
	for child in %FixtureSelectionContainer.get_children():
		child.queue_free()
		
	for fixture_res in available_fixtures:
		var element = ui_scenery_element.instantiate()
		element.resource = fixture_res
		element.scenery_type = 'fixture'
		%FixtureSelectionContainer.add_child(element)
		%UI.connect_ui_element(element)

func place_fixture(press_pos, fixture_res : fixture_resource, free_placement : bool, saved_direction):
	var cell = pathLayer.local_to_map(press_pos)
	var cell_central_pos = pathLayer.map_to_local(cell)
	var directions = []
	if saved_direction:
		directions = [saved_direction]
	else:
		if free_placement:
			directions = [Helpers.get_cell_quadrant(press_pos)]
		else:
			directions = get_fixture_directions(cell)
	if directions.is_empty():
		return
	for direction in directions:
		if str(cell) in used_cells.keys():
			for element in used_cells[str(cell)]:
				if element['direction'] == direction:
					return
		if pathLayer.get_cell_source_id(cell) == -1:
			return
			
		var fixture_scene
		if fixture_res.type == IdRefs.FIXTURES.BENCH:
			fixture_scene = bench_scene.instantiate()
		elif fixture_res.type == IdRefs.FIXTURES.DECORATION:
			if fixture_res.positioning == IdRefs.FIXTURE_POS.SIDE:
				fixture_scene = side_fixture.instantiate()
				
		fixture_scene.fixture_res = fixture_res
		fixture_scene.global_position = cell_central_pos
		fixture_scene.direction = direction
		fixture_scene.placement_global_pos = press_pos
		fixture_scene.remove_fixture.connect(on_remove_fixture)
		fixture_scene.cell = cell
		add_child(fixture_scene)
		if str(cell) in used_cells.keys():
			used_cells[str(cell)].append({'scene': fixture_scene, 'direction': direction})
		else:
			used_cells[str(cell)] = [{'scene': fixture_scene, 'direction': direction}]
	
func on_remove_fixture(scene):
	if str(scene.cell) not in used_cells.keys():
		return
	for element in used_cells[str(scene.cell)]:
		if element['scene'] == scene:
			used_cells[str(scene.cell)].erase(element)
	
	scene.queue_free()
	
func remove_fixture_from_path(cell):
	if str(cell) in used_cells.keys():
		for element in used_cells[str(cell)]:
			on_remove_fixture(element['scene'])

func replace_fixture(cell):
	return
	if cell not in used_cells:
		return
	
	remove_fixture_from_path(cell)

	place_fixture(TileMapRef.map_to_local(cell), available_fixtures[0], true, null)
	
func get_fixture_directions(cell):
	var path_x_atlas = TileMapRef.get_path_atlas(cell).x
	var fixture_directions = []
	if path_x_atlas == 0:
		fixture_directions = [3, 1]
	elif path_x_atlas == 1:
		fixture_directions = [0, 2]
	elif path_x_atlas == 2:
		return
	elif path_x_atlas == 3:
		fixture_directions = [3, 2]
	elif path_x_atlas == 4:
		fixture_directions = [1, 2]
	elif path_x_atlas == 5:
		fixture_directions = [3, 0]
	elif path_x_atlas == 6:
		fixture_directions = [1, 0]
	elif path_x_atlas == 7:
		fixture_directions = [3] #N
	elif path_x_atlas == 8:
		fixture_directions = [1] #S
	elif path_x_atlas == 9:
		fixture_directions = [0] #E
	elif path_x_atlas == 10:
		fixture_directions = [2] #W
	return fixture_directions
