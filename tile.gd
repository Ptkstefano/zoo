extends Node2D

class_name tile

@export var terrain : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Terrain.frame = terrain


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_terrain(value):
	print('change')
	$Terrain.frame = value
