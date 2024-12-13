extends Node2D

class_name BuildingManager

@export var available_buildings : Array[building_resource]
@export var building_class_scene : PackedScene
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
		print('here')
		var element = ui_building_element.instantiate()
		element.building_res = building_res
		print(element.building_res.building_menu)
		if element.building_res.building_menu == IdRefs.BUILDING_MENU.EATERY:
			%EaterySelectionContainer.add_child(element)
		if element.building_res.building_menu == IdRefs.BUILDING_MENU.RESTAURANT:
			%RestaurantSelectionContainer.add_child(element)
		if element.building_res.building_menu == IdRefs.BUILDING_MENU.SERVICE:
			%ServicesSelectionContainer.add_child(element)
		if element.building_res.building_menu == IdRefs.BUILDING_MENU.ADMINISTRATION:
			%AdministrationSelectionContainer.add_child(element)
		
	$"../../UI".update_ui()

func build_building(building_res : building_resource, start_tile, rotate, coords, data):
	var new_building = building_class_scene.instantiate()
	new_building.start_tile = start_tile
	new_building.is_building_rotated = rotate
	new_building.building_res = building_res
	new_building.used_coordinates = coords
	new_building.building_res_id = building_res.id
	SignalBus.set_debug_label_text.emit(str(building_res.id))
	if !data:
		new_building.id = ZooManager.generate_building_id()
	else:
		new_building.load_data = data
	add_child(new_building)
	new_building.building_selected.connect(on_building_selected)
	new_building.building_removed.connect(on_building_removed)
	print(new_building.id)
	if building_res.building_type == IdRefs.BUILDING_TYPES.EATERY:
		ZooManager.add_eatery(new_building.id, { 'building': new_building, 'position': TileMapRef.map_to_local(start_tile) })
	if building_res.building_type == IdRefs.BUILDING_TYPES.RESTAURANT:
		ZooManager.add_restaurant(new_building.id, { 'building': new_building, 'position': TileMapRef.map_to_local(start_tile) })
	if building_res.building_type == IdRefs.BUILDING_TYPES.TOILET:
		ZooManager.add_toilet(new_building.id, { 'building': new_building, 'position': TileMapRef.map_to_local(start_tile) })
			
	$"../../PathManager".build_building_path(coords)
	coordinates_used_by_buildings.append(coords)
	
func on_building_removed(building_node):
	for coordinate in building_node.used_coordinates:
		coordinates_used_by_buildings.erase(coordinate)
	if building_node.building_res.product_types.has(IdRefs.PRODUCT_TYPES.FOOD):
		ZooManager.remove_food_shop(building_node.id)
	if building_node.building_res.building_type == IdRefs.BUILDING_TYPES.TOILET:
		ZooManager.remove_toilet(building_node.id)
	$"../../PathManager".remove_path(building_node.used_coordinates)

func on_building_selected(building_node):
	$"../../PopupManager".open_building_popup(building_node)
	
