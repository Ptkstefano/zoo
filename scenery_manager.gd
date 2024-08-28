extends Node2D

class_name SceneryManager

@export var debug_tree : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func plop(press_start_pos):
	var tree = debug_tree.instantiate()
	tree.global_position = press_start_pos
	tree.z_index = Helpers.get_current_tile_z_index(press_start_pos)
	add_child(tree)
	
func remove(press_start_pos):
	pass
