extends Node2D

var fixture_res : fixture_resource

var fixture_directions : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for children in $Directions.get_children():
		if children.name not in fixture_directions:
			children.visible = false
			continue
		children.texture = fixture_res.texture

	z_index = Helpers.get_current_tile_z_index(global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
