extends Node2D

class_name RockDecoration

var type = IdRefs.SCENERY_TYPES.ROCK

var category = 'rock'

var rock_res : rock_resource

signal removed

var id : int

var cached_position : Vector2

var cell : Vector2

func _ready() -> void:
	$RemovalArea.area_entered.connect(on_removal)
	$Sprite2D.texture = rock_res.texture
	#$Sprite2D.offset = Vector2($Sprite2D.texture.get_width() * -0.5, ($Sprite2D.texture.get_height() * -0.5))
	$Sprite2D.offset = Vector2(0, int($Sprite2D.texture.get_height() * -0.5))
	z_index = Helpers.get_current_tile_z_index(global_position)
	cached_position = global_position


func on_removal(bulldozer):
	removed.emit(cell)
	queue_free()
