extends Node2D

var sprite_x = 0
var sprite_y = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update_fence_instance(fence_res):
	$Sprite2D.frame_coords = Vector2(sprite_x, fence_res.atlas_y)
	update_collision(sprite_x)

func update_collision(x):
	if x == 0:
		$CollisionSides/N.disabled = false
	if x == 1:
		$CollisionSides/W.disabled = false
	if x == 2:
		$CollisionSides/S.disabled = false
	if x == 3:
		$CollisionSides/E.disabled = false
