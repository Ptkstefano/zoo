extends Node2D

@export var available_buildings : Array[building_resource]
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
	var new_building = building_res.building_scene.instantiate()
	new_building.global_position = $"../../TileMap/TerrainLayer".map_to_local(starting_coord)
	new_building.z_index = Helpers.get_current_tile_z_index(new_building.global_position)
	new_building.on_built(rotate)
	add_child(new_building)
	$"../../PathManager".build_building_path(coords)
	coordinates_used_by_buildings.append(coords)
	pass
