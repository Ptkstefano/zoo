extends Node2D

class_name BuildingManager

@export var available_buildings : Array[building_resource]

@export var ui_building_element : PackedScene

#@onready var building_menu = %BuildingSelectionContainer

var coordinates_used_by_buildings = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_building_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_building_menu():
	for child in %EaterySelectionContainer.get_children():
		child.queue_free()
	for child in %RestaurantSelectionContainer.get_children():
		child.queue_free()
	for child in %ServicesSelectionContainer.get_children():
		child.queue_free()
	for child in %AdministrationSelectionContainer.get_children():
		child.queue_free()
		
	for building_res in available_buildings:
		var element = ui_building_element.instantiate()
		element.building_res = building_res
		if element.building_res.building_menu == IdRefs.BUILDING_MENU.EATERY:
			%EaterySelectionContainer.add_child(element)
		if element.building_res.building_menu == IdRefs.BUILDING_MENU.RESTAURANT:
			%RestaurantSelectionContainer.add_child(element)
		if element.building_res.building_menu == IdRefs.BUILDING_MENU.SERVICE:
			%ServicesSelectionContainer.add_child(element)
		if element.building_res.building_menu == IdRefs.BUILDING_MENU.ADMINISTRATION:
			%AdministrationSelectionContainer.add_child(element)
		%UI.connect_ui_element(element)

func build_building(building_res : building_resource, start_tile, direction, data):
	if !building_res:
		return
		
	var building_id
		
	if !data:
		if !FinanceManager.is_amount_available(building_res.building_cost):
			SignalBus.tooltip.emit('Not enough money')
			return
		FinanceManager.remove(building_res.building_cost, IdRefs.PAYMENT_REMOVE_TYPES.CONSTRUCTION)
		building_id = ZooManager.generate_building_id()
	else:
		building_id = data.id
	
	var new_building = building_res.building_scene.instantiate()
	new_building.id = int(building_id)
	new_building.start_tile = start_tile
	new_building.direction = direction
	new_building.building_res = building_res
	new_building.is_shop = building_res.is_shop
	new_building.global_position = TileMapRef.map_to_local(start_tile)
	var used_cells = Helpers.get_building_cells(building_res.size, start_tile, direction)
	new_building.used_coordinates = used_cells
	new_building.building_res_id = building_res.id
	SignalBus.set_debug_label_text.emit(str(building_res.id))

	if data:
		if data.has('shop_data'):
			new_building.product_load_data = data.shop_data

	add_child(new_building)
	
	new_building.building_selected.connect(on_building_selected)
	new_building.building_removed.connect(on_building_removed)
	
	
	if building_res.building_type == IdRefs.BUILDING_TYPES.EATERY:
		ZooManager.add_eatery(new_building.id, { 'scene': new_building, 'position': TileMapRef.map_to_local(start_tile) })
	if building_res.building_type == IdRefs.BUILDING_TYPES.RESTAURANT:
		ZooManager.add_restaurant(new_building.id, { 'scene': new_building, 'position': TileMapRef.map_to_local(start_tile) })
	if building_res.building_type == IdRefs.BUILDING_TYPES.TOILET:
		ZooManager.add_toilet(new_building.id, { 'scene': new_building, 'position': TileMapRef.map_to_local(start_tile) })
	if building_res.building_type == IdRefs.BUILDING_TYPES.ZOOKEEPER_STATION:
		ZooManager.add_zookeeper_station(new_building.id, { 'scene': new_building, 'position': TileMapRef.map_to_local(start_tile) })
			
	$"../../PathManager".build_building_path(used_cells)
	for coord in used_cells:
		coordinates_used_by_buildings.append(coord)
	
func on_building_removed(building_node):
	for coordinate in building_node.used_coordinates:
		coordinates_used_by_buildings.erase(coordinate)
	if building_node.building_type == IdRefs.BUILDING_TYPES.RESTAURANT:
		ZooManager.remove_restaurant(building_node.id)
	if building_node.building_type == IdRefs.BUILDING_TYPES.EATERY:
		ZooManager.remove_eatery(building_node.id)
	if building_node.building_type == IdRefs.BUILDING_TYPES.TOILET:
		ZooManager.remove_toilet(building_node.id)
	if building_node.building_type == IdRefs.BUILDING_TYPES.ZOOKEEPER_STATION:
		ZooManager.remove_zookeeper_station(building_node.id)
	$"../../PathManager".remove_path(building_node.used_coordinates)
	building_node.queue_free()

func on_building_selected(building_node):
	$"../../PopupManager".open_building_popup(building_node)
	
