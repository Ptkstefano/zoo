extends Node2D

class_name building_food

@export var sprite_offset : Vector2
@export var sprite_offset_rotated : Vector2

@export var detectable_pos : Vector2
@export var detectable_pos_rotated : Vector2

var shop_name
var coordinates = []

var is_rotated : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for sprite in $Sprites.get_children():
		if is_rotated:
			sprite.flip_h = true
			sprite.offset = sprite_offset_rotated
		else:
			sprite.flip_h = false
			sprite.offset = sprite_offset
