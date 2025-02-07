extends Node2D

class_name SceneryManager

@export var available_trees : Array[tree_resource]
@export var available_decorations : Array[decoration_resource]
@export var available_vegetations : Array[vegetation_resource]
@export var available_rocks : Array[rock_resource]

@export var tree_scene : PackedScene
@export var vegetation_scene : PackedScene
@export var decoration_scene : PackedScene
@export var rock_scene : PackedScene

@export var ui_scenery_element : PackedScene

@export var buildingManager : BuildingManager

var used_cells = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_selection_menu()


func on_load_scenery(scenery_type, id, coordinates, rotate_building, res):
	if scenery_type == IdRefs.SCENERY_TYPES.TREE:
		place_tree(coordinates, res, id)
	elif scenery_type == IdRefs.SCENERY_TYPES.VEGETATION:
		place_vegetation(coordinates, res, id)
	elif scenery_type == IdRefs.SCENERY_TYPES.DECORATION:
		place_decoration(coordinates, res, rotate_building, id)
	elif scenery_type == IdRefs.SCENERY_TYPES.ROCK:
		place_rock(coordinates, res, id)
	
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
		
	for rock_res in available_rocks:
		var element = ui_scenery_element.instantiate()
		element.resource = rock_res
		element.scenery_type = 'rock'
		%RockSelectionContainer.add_child(element)
		
	$"../../UI".update_ui()

func place_tree(press_start_pos, tree_res, id):
	if !tree_res:
		return
	var tree = tree_scene.instantiate()
	tree.tree_res = tree_res
	tree.global_position = press_start_pos
	AudioManager.play_tree_placed()
	if !id:
		tree.id = ZooManager.generate_scenery_id()
		FinanceManager.remove(tree_res.cost, IdRefs.PAYMENT_REMOVE_TYPES.CONSTRUCTION)
		SignalBus.money_tooltip.emit(tree_res.cost, false, press_start_pos)
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
	
func place_vegetation(press_start_pos, vegetation_res : vegetation_resource, id):
	var vegetation = vegetation_scene.instantiate()
	
	vegetation.vegetation_res = vegetation_res
	vegetation.global_position = press_start_pos
	AudioManager.play_vegetation_placed()
	if !id:
		if !FinanceManager.is_amount_available(vegetation_res.cost):
			SignalBus.tooltip.emit('Not enough money')
			return
		vegetation.id = ZooManager.generate_scenery_id()
		FinanceManager.remove(vegetation_res.cost, IdRefs.PAYMENT_REMOVE_TYPES.CONSTRUCTION)
		SignalBus.money_tooltip.emit(vegetation_res.cost, false, press_start_pos)
	else:
		vegetation.id = id
	add_child(vegetation)
	await get_tree().create_timer(0.3).timeout
	#$"../../RenderingController".add_object(vegetation)
	vegetation.object_removed.connect(on_object_removed)
	Effects.wobble(vegetation)
	SignalBus.vegetation_placed.emit(vegetation.global_position)
	
func place_decoration(press_start_pos, decoration_res, direction, id):
	var decoration_position_cell = TileMapRef.local_to_map(press_start_pos)
	var decoration_position_local = TileMapRef.map_to_local(decoration_position_cell)
	if decoration_position_cell in used_cells:
		return
	var decoration = decoration_scene.instantiate()
	decoration.decoration_res = decoration_res
	decoration.global_position = decoration_position_local
	if !id:
		if !FinanceManager.is_amount_available(decoration_res.cost):
			SignalBus.tooltip.emit('Not enough money')
			return
		decoration.id = ZooManager.generate_scenery_id()
		FinanceManager.remove(decoration_res.cost, IdRefs.PAYMENT_REMOVE_TYPES.CONSTRUCTION)
		SignalBus.money_tooltip.emit(decoration_res.cost, false, press_start_pos)
	else:
		decoration.id = id
	decoration.cell = decoration_position_cell
	decoration.direction = direction
	decoration.removed.connect(on_decoration_removed)
	used_cells.append(decoration_position_cell)
	add_child(decoration)
	Effects.wobble(decoration)
	
func place_rock(press_start_pos, rock_res, id):
	var rock = rock_scene.instantiate()
	rock.rock_res = rock_res
	rock.global_position = press_start_pos
	if !id:
		if !FinanceManager.is_amount_available(rock_res.cost):
			SignalBus.tooltip.emit('Not enough money')
			return
		rock.id = ZooManager.generate_scenery_id()
		FinanceManager.remove(rock_res.cost, IdRefs.PAYMENT_REMOVE_TYPES.CONSTRUCTION)
		SignalBus.money_tooltip.emit(rock_res.cost, false, press_start_pos)
	else:
		rock.id = id
	add_child(rock)
	await get_tree().create_timer(0.3).timeout
	#$"../../RenderingController".add_object(rock)
	#rock.object_removed.connect(on_object_removed)
	Effects.wobble(rock)
	
func on_decoration_removed(cell):

	used_cells.erase(Vector2i(cell.x, cell.y))
	
	
func remove(press_start_pos):
	pass

func on_object_removed(object):
	var cell = TileMapRef.local_to_map(object.global_position)
	if object is SceneryTree:
		var enclosure = TileMapRef.get_enclosure_by_cell(cell)
		if enclosure:
			enclosure.call_deferred('update_navigation_region')
	object.queue_free()
