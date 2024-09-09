extends Node2D

@export var sprite_offset : Vector2
@export var sprite_offset_rotated : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_built(rotate):
		for sprite in $Sprites.get_children():
			if rotate:
				sprite.flip_h = true
				sprite.offset = sprite_offset_rotated
			else:
				sprite.flip_h = false
				sprite.offset = sprite_offset
