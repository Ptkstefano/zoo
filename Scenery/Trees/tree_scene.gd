extends StaticBody2D
 
@export var tree_sheet : Texture2D

var tree_res : tree_resource

var texture : Texture2D

var vegetation_weight

signal object_removed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RemovalArea.area_entered.connect(on_removal)
	$Sprite2D.vframes = tree_sheet.get_height() / 128
	$Sprite2D.hframes = tree_sheet.get_width() / 128
	$Sprite2D.frame_coords = Vector2(tree_res.texture_y, 0)
	texture = tree_sheet
	var y = -128
	var x = -128 * 0.5
	$Sprite2D.offset = Vector2(x,y)
	$Sprite2D.z_index = Helpers.get_current_tile_z_index(global_position)
	#$Shadow.z_index = Helpers.get_current_tile_z_index(global_position)
	vegetation_weight = tree_res.vegetation_weight
	Effects.wobble(self)
	#await get_tree().create_timer(0.5).timeout
	#$Sprite2D.visible = false

func on_removal(bulldozer):
	$RemovalArea/CollisionShape2D.disabled = true
	object_removed.emit(self)
	#queue_free()