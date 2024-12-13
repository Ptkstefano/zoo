extends Node

class_name building

@export var shop_scene : PackedScene
@export var toilet_scene : PackedScene

var building_type : IdRefs.BUILDING_TYPES

var building_scene

var building_res : building_resource
var building_res_id

var id : int

var load_data

var used_coordinates = []
var start_tile : Vector2

var is_building_rotated : bool

signal building_selected
signal building_removed

func _ready() -> void:
	var building_instance
	if building_res.building_type == IdRefs.BUILDING_TYPES.EATERY or building_res.building_type == IdRefs.BUILDING_TYPES.RESTAURANT:
		building_instance = shop_scene.instantiate()
	if building_res.building_type == IdRefs.BUILDING_TYPES.TOILET:
		building_instance = toilet_scene.instantiate()
	building_instance.building_res = building_res
	building_instance.building_res_id = building_res_id
	building_instance.global_position = TileMapRef.map_to_local(start_tile)
	building_instance.z_index = Helpers.get_current_tile_z_index(building_instance.global_position) + building_res.z_offset
	building_instance.is_rotated = is_building_rotated
	building_scene = building_instance
	if load_data:
		building_instance.restore_data(load_data)
	add_child(building_instance)
	
	SignalBus.pass_month.connect(on_pass_month)

func remove_building():
	building_removed.emit(self)
	queue_free()

func on_pass_month():
	FinanceManager.remove(building_res.base_maintenance, IdRefs.PAYMENT_REMOVE_TYPES.BUILDING_MAINTENANCE)
