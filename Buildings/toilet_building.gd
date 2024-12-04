extends Node2D
class_name Toilet

var building_res : building_resource
var building_res_id
#var shop_name
var coordinates = []

var enter_positions : Array[Vector2]

var is_rotated : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprites/Sprite2D.texture = building_res.texture
	if is_rotated:
		$Sprites/Sprite2D.flip_h = true
		$Sprites.position = building_res.sprite_pos_rotated
		for children in $EnterPositionsRotated.get_children():
			enter_positions.append(children.global_position)
	else:
		$Sprites/Sprite2D.flip_h = false
		$Sprites.position = building_res.sprite_pos
		for children in $EnterPositions.get_children():
			enter_positions.append(children.global_position)

func remove_building():
	get_parent().remove_building()
