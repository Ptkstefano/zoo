extends Node2D

var world_width : int = 100
var world_height : int = 100

var tile_size = Vector2(60, 30)

@export var tile_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	for i in world_width:
		for j in world_height:
			var tile = tile_scene.instantiate()
			tile.global_position = Vector2(tile_size.x * i, tile_size.y * j)
			add_child(tile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
