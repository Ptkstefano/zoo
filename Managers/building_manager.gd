extends Node2D

class_name BuildingManager

@export var available_buildings : Array[building_resource]
@export var building_class_scene : PackedScene
@export var ui_building_element : PackedScene

@onready var building_menu = %BuildingSelectionContainer

var coordinates_used_by_buildings = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_building_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_building_menu():
	for child in building_menu.get_children():
		child.queue_free()
		
	for building_res in available_buildings:
		var element = ui_building_element.instantiate()
		element.building_res = building_res
		building_menu.add_child(element)
		
	$"../../UI".update_ui()

func build_building(building_res, starting_coord, rotate, coords):
	var new_building = building_class_scene.instantiate()
	new_building.building_position = $"../../TileMap/TerrainLayer".map_to_local(starting_coord)
	new_building.is_building_rotated = rotate
	new_building.building_res = building_res
	new_building.used_coordinates = coords
	add_child(new_building)
	new_building.building_selected.connect(on_building_selected)
	new_building.building_removed.connect(on_building_removed)
	$"../../PathManager".build_building_path(coords)
	coordinates_used_by_buildings.append(coords)
	
func on_building_removed(building_node):
	for coordinate in building_node.used_coordinates:
		coordinates_used_by_buildings.erase(coordinate)
	$"../../PathManager".remove_path(building_node.used_coordinates)

func on_building_selected(building_node):
	$"../../PopupManager".open_building_popup(building_node)
	
