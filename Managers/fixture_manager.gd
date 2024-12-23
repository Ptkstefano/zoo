extends Node2D
class_name FixtureManager

@export var available_fixtures : Array[fixture_resource]

@export var bench_scene : PackedScene

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
		
	$"../../UI".update_ui()

func place_fixture(press_pos, fixture_res : fixture_resource):
	#var fixture_direction
	#if path_x_atlas == 0:
		#fixture_direction = ['N', 'S']
	#elif path_x_atlas == 1:
		#fixture_direction = ['E', 'W']
	#elif path_x_atlas == 2:
		#return
	#elif path_x_atlas == 3:
		#fixture_direction = ['N', 'W']
	#elif path_x_atlas == 4:
		#fixture_direction = ['S', 'W']
	#elif path_x_atlas == 5:
		#fixture_direction = ['N', 'E']
	#elif path_x_atlas == 6:
		#fixture_direction = ['S', 'E']
	#elif path_x_atlas == 7:
		#fixture_direction = ['N']
	#elif path_x_atlas == 8:
		#fixture_direction = ['S']
	#elif path_x_atlas == 9:
		#fixture_direction = ['E']
	#elif path_x_atlas == 10:
		#fixture_direction = ['W']

	if fixture_res.type == IdRefs.FIXTURES.BENCH:
		var cell = pathLayer.local_to_map(press_pos)
		var cell_central_pos = pathLayer.map_to_local(cell)
		var direction = Helpers.get_cell_quadrant(press_pos)
		for fixture in used_cells.keys():
			if used_cells[fixture].cell == cell:
				if used_cells[fixture].direction == direction:
					return
		if pathLayer.get_cell_source_id(cell) == -1:
			return
		var fixture = bench_scene.instantiate()
		fixture.fixture_res = fixture_res
		fixture.global_position = cell_central_pos
		fixture.direction = Helpers.get_cell_quadrant(press_pos)
		fixture.placement_global_pos = press_pos
		fixture.remove_fixture.connect(on_remove_fixture)
		fixture.cell = cell
		add_child(fixture)
		used_cells[fixture] = {'cell': cell, 'direction': direction}
	
func on_remove_fixture(scene):
	used_cells.erase(scene)
	scene.queue_free()
	
func remove_fixture_from_path(cell):
	for child in get_children():
		child.cell == cell
		on_remove_fixture(child)
	

func replace_fixture(cell):
	return
	if cell not in used_cells:
		return
	
	remove_fixture_from_path(cell)

	place_fixture(TileMapRef.map_to_local(cell), available_fixtures[0])
	
