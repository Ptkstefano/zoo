extends Node2D

@export var sprite_offset : Vector2
@export var sprite_offset_rotated : Vector2

@export var detectable_pos : Vector2
@export var detectable_pos_rotated : Vector2

var shop_name
var coordinates = []

var is_rotated : bool

signal building_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Detectable.on_clicked.connect(on_selected)
	for sprite in $Sprites.get_children():
		if is_rotated:
			sprite.flip_h = true
			sprite.offset = sprite_offset_rotated
		else:
			sprite.flip_h = false
			sprite.offset = sprite_offset

func on_selected():
	building_selected.emit()
