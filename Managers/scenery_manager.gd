extends Node2D

class_name SceneryManager

@export var available_trees : Array[tree_resource]
@export var available_decorations : Array[decoration_resource]
@export var available_vegetations : Array[vegetation_resource]

@export var tree_scene : PackedScene
@export var vegetation_scene : PackedScene
@export var decoration_scene : PackedScene

@export var ui_scenery_element : PackedScene

@export var buildingManager : BuildingManager

var used_cells = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	update_selection_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_selection_menu():
	for child in %TreesSelectionContainer.get_children():
		child.queue_free()
	for child in %TreesSelectionContainer.get_children():
		child.queue_free()
		
	for tree_res in available_trees:
		var element = ui_scenery_element.instantiate()
		element.resource = tree_res
		element.scenery_type = 'tree'
		%TreesSelectionContainer.add_child(element)
		
	for vegetation_res in available_vegetations:
		var element = ui_scenery_element.instantiate()
		element.resource = vegetation_res
		element.scenery_type = 'vegetation'
		%VegetationSelectionContainer.add_child(element)
		
	for decoration_res in available_decorations:
		var element = ui_scenery_element.instantiate()
		element.resource = decoration_res
		element.scenery_type = 'decoration'
		%DecorationSelectionContainer.add_child(element)
		
	$"../../UI".update_ui()

func place_tree(press_start_pos, tree_res):
	var tree = tree_scene.instantiate()
	tree.tree_res = tree_res
	tree.global_position = press_start_pos
	add_child(tree)
	await get_tree().create_timer(0.3).timeout
	#$"../../RenderingController".add_object(tree)
	tree.object_removed.connect(on_object_removed)
	var enclosure = TileMapRef.get_enclosure_by_cell(TileMapRef.local_to_map(tree.global_position))
	if enclosure:
		enclosure.call_deferred('update_navigation_region')
	SignalBus.vegetation_placed.emit(tree.global_position)
	#SignalBus.save_game.emit()
	SignalBus.save_new_scenery.emit(tree)
	
func place_vegetation(press_start_pos, vegetation_res):
	var vegetation = vegetation_scene.instantiate()
	vegetation.vegetation_res = vegetation_res
	vegetation.global_position = press_start_pos
	add_child(vegetation)
	await get_tree().create_timer(0.3).timeout
	#$"../../RenderingController".add_object(vegetation)
	vegetation.object_removed.connect(on_object_removed)
	Effects.wobble(vegetation)
	SignalBus.vegetation_placed.emit(vegetation.global_position)
	#SignalBus.save_game.emit()
	SignalBus.save_new_scenery.emit(vegetation)
	
func place_decoration(press_start_pos, decoration_res):
	var decoration_position_cell = TileMapRef.local_to_map(press_start_pos)
	var decoration_position_local = TileMapRef.map_to_local(decoration_position_cell)
	if decoration_position_cell in used_cells:
		return
	var decoration = decoration_scene.instantiate()
	decoration.resource = decoration_res
	decoration.global_position = decoration_position_local
	decoration.cell = decoration_position_cell
	decoration.removed.connect(on_decoration_removed)
	used_cells.append(decoration_position_cell)
	add_child(decoration)
	Effects.wobble(decoration)
	#SignalBus.save_game.emit()
	SignalBus.save_new_scenery.emit(decoration)
	
func on_decoration_removed(cell):
	used_cells.erase(Vector2i(cell.x, cell.y))
	
	
func remove(press_start_pos):
	pass

func on_object_removed(object):
	#$"../../RenderingController".remove_object(object)
	object.queue_free()
