extends Node

class_name building

enum BUILDING_TYPES {FOOD}

var building_type : BUILDING_TYPES

var building_res : building_resource

var used_coordinates = []

var building_position : Vector2
var is_building_rotated : bool

signal building_selected
signal building_removed

func _ready() -> void:
	var building_instance = building_res.building_scene.instantiate()
	building_instance.global_position = building_position
	building_instance.z_index = Helpers.get_current_tile_z_index(building_position) + building_res.z_offset
	building_instance.is_rotated = is_building_rotated
	add_child(building_instance)
	building_instance.building_selected.connect(on_building_selected)

func on_building_selected():
	building_selected.emit(self)

func remove_building():
	building_removed.emit(self)
	queue_free()
