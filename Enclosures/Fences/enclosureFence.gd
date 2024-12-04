extends Node2D

var sprite_x = 0
var sprite_y = 0

var dir : int
var cell : Vector2

var g_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position.y = g_pos.y - 15
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(g_pos.x, g_pos.y), 0.5).set_trans(Tween.TRANS_ELASTIC)
	await get_tree().create_timer(0.2).timeout
	z_index = Helpers.get_current_tile_z_index(g_pos)
	Effects.smoke2(g_pos)

func update_fence_instance(enclosure_res):
	$Sprite2D.frame_coords = Vector2(sprite_x, enclosure_res.atlas_y)


func make_entrance():
	$Sprite2D.frame_coords = Vector2($Sprite2D.frame_coords.x + 4, $Sprite2D.frame_coords.y)
	print(dir)

	return sprite_x

func remove_entrance():
	$Sprite2D.frame_coords = Vector2($Sprite2D.frame_coords.x - 4, $Sprite2D.frame_coords.y)

func open_door():
	if $Sprite2D.frame_coords.x < 4:
		return
	else:
		$Sprite2D.frame_coords.x = $Sprite2D.frame_coords.x + 4
		await get_tree().create_timer(2.5).timeout
		$Sprite2D.frame_coords.x = $Sprite2D.frame_coords.x - 4
