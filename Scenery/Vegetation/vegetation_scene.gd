extends Node2D


var vegetation_res : vegetation_resource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RemovalArea.area_entered.connect(on_removal)
	$Sprite2D.texture = vegetation_res.texture
	$Sprite2D.offset = vegetation_res.texture_offset
	z_index = Helpers.get_current_tile_z_index(global_position)


func on_removal(bulldozer):
	queue_free()
