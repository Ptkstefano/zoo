extends Node2D

@export var available_fixtures : Array[fixture_resource]

@export var fixture_scene : PackedScene

@export var ui_scenery_element : PackedScene

@export var pathLayer : TileMapLayer

var used_cells = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_selection_menu()


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

func place_fixture(press_start_pos, fixture_res):
	var path_cell = pathLayer.local_to_map(press_start_pos)
	if path_cell in used_cells:
		return
	if pathLayer.get_cell_source_id(path_cell) == -1:
		return
	var path_x_atlas = pathLayer.get_cell_atlas_coords(path_cell).x
	var fixture_direction
	if path_x_atlas == 0:
		fixture_direction = ['N', 'S']
	elif path_x_atlas == 1:
		fixture_direction = ['E', 'W']
	elif path_x_atlas == 2:
		return
	elif path_x_atlas == 3:
		fixture_direction = ['N', 'W']
	elif path_x_atlas == 4:
		fixture_direction = ['S', 'W']
	elif path_x_atlas == 5:
		fixture_direction = ['N', 'E']
	elif path_x_atlas == 6:
		fixture_direction = ['S', 'E']
	elif path_x_atlas == 7:
		fixture_direction = ['N']
	elif path_x_atlas == 8:
		fixture_direction = ['S']
	elif path_x_atlas == 9:
		fixture_direction = ['E']
	elif path_x_atlas == 10:
		fixture_direction = ['W']
	
	var path_central_pos = pathLayer.map_to_local(path_cell)
	var fixture = fixture_scene.instantiate()
	fixture.fixture_res = fixture_res
	fixture.global_position = path_central_pos
	fixture.fixture_directions = fixture_direction
	add_child(fixture)
	used_cells.append(path_cell)
	
