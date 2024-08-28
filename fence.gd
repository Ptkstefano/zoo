extends Node2D

var sprite_x = 0
var sprite_y = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update_fence_instance():
	$Sprite2D.frame_coords = Vector2(sprite_x, sprite_y)
	#if sprite_x < 2:
		#$Sprite2D.offset = Vector2(0, -32)
		#$Sprite2D.position = Vector2(0, 16)
	#else:
		#$Sprite2D.offset = Vector2(0, 0)
		#$Sprite2D.position = Vector2(0, 16)
