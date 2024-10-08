extends Node2D

@export var z_index_renderer : PackedScene
var z_index_range = 270

var z_renderers = {}

## Instantiates a rendering node for every possible Z-Index
## Rendering nodes handle draw calls for textures

func _ready() -> void:
	for i in range(-z_index_range, z_index_range):
		var node = z_index_renderer.instantiate()
		node.z_index_value = i
		node.z_index = i
		node.name = str(i)
		node.rendering_controller = self
		add_child(node)
		z_renderers[i] = node


func add_object(object):
	var index = Helpers.get_current_tile_z_index(object.global_position)
	var node = z_renderers[index]
	node.add_object(object)
	

	
#func remove_object(object):
	#objects_to_render.erase(object)
	#
