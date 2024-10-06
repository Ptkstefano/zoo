extends Node2D

var z_index_value : int
var rendering_controller

var render_objects = {}

@export var shadow_texture_s : Texture2D
@export var shadow_texture_m : Texture2D
@export var shadow_texture_b : Texture2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if render_objects.size() > 0:
		queue_redraw()

func add_object(object):
	render_objects[object] = { 'index': Helpers.get_current_tile_z_index(object.global_position),
		'position': object.global_position,
		'texture': object.texture
	} 

func _draw():
	for object in render_objects:
		var x = object.position.x - object.texture.get_width() * 0.5
		var y = object.position.y - object.texture.get_height()
		draw_texture(object.texture, Vector2(x,y))
		#var shadow_texture = shadow_texture_b
		#var shadow_x = object.position.x - shadow_texture.get_width() * 0.5
		#var shadow_y = object.position.y - shadow_texture.get_height()
		#draw_texture(shadow_texture, Vector2(shadow_x,shadow_y), Color(1,1,1,1))
