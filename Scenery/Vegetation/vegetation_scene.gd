extends Node2D


var vegetation_res : vegetation_resource
var vegetation_weight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RemovalArea.area_entered.connect(on_removal)
	$Sprite2D.texture = vegetation_res.texture
	$Sprite2D.offset = vegetation_res.texture_offset
	z_index = Helpers.get_current_tile_z_index(global_position)
	vegetation_weight = vegetation_res.vegetation_weight


func on_removal(bulldozer):
	queue_free()
