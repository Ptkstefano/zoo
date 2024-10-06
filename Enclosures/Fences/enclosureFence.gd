extends Node2D

var sprite_x = 0
var sprite_y = 0

var g_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position.y = g_pos.y - 15
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(g_pos.x, g_pos.y), 0.5).set_trans(Tween.TRANS_ELASTIC)
	await get_tree().create_timer(0.2).timeout
	Effects.smoke2(g_pos)

func update_fence_instance(enclosure_res):
	$Sprite2D.frame_coords = Vector2(sprite_x, enclosure_res.atlas_y)
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
