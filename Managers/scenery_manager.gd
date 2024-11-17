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


func on_load_scenery(scenery_type, id, coordinates, res):
	if scenery_type == IdRefs.SCENERY_TYPES.TREE:
		place_tree(coordinates, res, id)
	elif scenery_type == IdRefs.SCENERY_TYPES.VEGETATION:
		place_vegetation(coordinates, res, id)
	elif scenery_type == IdRefs.SCENERY_TYPES.DECORATION:
		place_decoration(coordinates, res, id)
	
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

func place_tree(press_start_pos, tree_res, id):
	var tree = tree_scene.instantiate()
	tree.tree_res = tree_res
	tree.global_position = press_start_pos
	if !id:
		tree.id = ZooManager.generate_scenery_id()
	else:
		tree.id = id
	add_child(tree)
	await get_tree().create_timer(0.3).timeout
	#$"../../RenderingController".add_object(tree)
	tree.object_removed.connect(on_object_removed)
	var enclosure = TileMapRef.get_enclosure_by_cell(TileMapRef.local_to_map(tree.global_position))
	if enclosure:
		enclosure.call_deferred('update_navigation_region')
	SignalBus.vegetation_placed.emit(tree.global_position)
	
func place_vegetation(press_start_pos, vegetation_res, id):
	var vegetation = vegetation_scene.instantiate()
	vegetation.vegetation_res = vegetation_res
	vegetation.global_position = press_start_pos
	if !id:
		vegetation.id = ZooManager.generate_scenery_id()
	else:
		vegetation.id = id
	add_child(vegetation)
	await get_tree().create_timer(0.3).timeout
	#$"../../RenderingController".add_object(vegetation)
	vegetation.object_removed.connect(on_object_removed)
	Effects.wobble(vegetation)
	SignalBus.vegetation_placed.emit(vegetation.global_position)
	
func place_decoration(press_start_pos, decoration_res, id):
	var decoration_position_cell = TileMapRef.local_to_map(press_start_pos)
	var decoration_position_local = TileMapRef.map_to_local(decoration_position_cell)
	if decoration_position_cell in used_cells:
		return
	var decoration = decoration_scene.instantiate()
	decoration.decoration_res = decoration_res
	decoration.global_position = decoration_position_local
	if !id:
		decoration.id = ZooManager.generate_scenery_id()
	else:
		decoration.id = id
	decoration.cell = decoration_position_cell
	decoration.removed.connect(on_decoration_removed)
	used_cells.append(decoration_position_cell)
	add_child(decoration)
	Effects.wobble(decoration)
	
func on_decoration_removed(cell):
	used_cells.erase(Vector2i(cell.x, cell.y))
	
	
func remove(press_start_pos):
	pass

func on_object_removed(object):
	#$"../../RenderingController".remove_object(object)
	object.queue_free()
