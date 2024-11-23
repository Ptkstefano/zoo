extends Node

class_name building

@export var shop_scene : PackedScene
@export var toilet_scene : PackedScene

var building_type : IdRefs.BUILDING_TYPES

var building_scene

var building_res : building_resource

var id : int

var used_coordinates = []
var start_tile : Vector2

var is_building_rotated : bool

signal building_selected
signal building_removed

func _ready() -> void:
	var building_instance
	if building_res.building_type == IdRefs.BUILDING_TYPES.SHOP:
		building_instance = shop_scene.instantiate()
	if building_res.building_type == IdRefs.BUILDING_TYPES.TOILET:
		building_instance = toilet_scene.instantiate()
	building_instance.building_res = building_res
	building_instance.global_position = TileMapRef.map_to_local(start_tile)
	building_instance.z_index = Helpers.get_current_tile_z_index(building_instance.global_position) + building_res.z_offset
	building_instance.is_rotated = is_building_rotated
	building_scene = building_instance
	add_child(building_instance)

func remove_building():
	building_removed.emit(self)
	queue_free()
