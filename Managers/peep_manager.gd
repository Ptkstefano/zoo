extends Node2D

class_name PeepManager

@export var peep_scene : PackedScene
@export var peep_group_scene : PackedScene
var spawn_location : Vector2

@export var path_manager : PathManager

var peep_groups = []

var peep_count : int = 0

@export var peep_texture_body : Texture2D
@export var peep_texture_head : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_location = path_manager.path_layer.map_to_local(Vector2(0,45))
	$PeepSpawnTimer.timeout.connect(on_peep_spawn_timeout)
	on_peep_spawn_timeout()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#queue_redraw()
	pass

func on_peep_spawn_timeout():
	var new_peep_group = peep_group_scene.instantiate()
	new_peep_group.global_position = spawn_location
	new_peep_group.peep_manager = self
	add_child(new_peep_group)
	peep_groups.append(new_peep_group)
	new_peep_group.peep_group_left.connect(on_peep_group_left)
	peep_count += new_peep_group.peep_count
	
func on_peep_group_left(group):
	## TODO - update zoo status
	peep_count -= group.peep_count
	group.queue_free()


func generate_peep_destination():
	## DEPRECATED
	return path_manager.generate_peep_destination()
	
func debug_clear_peeps():
	for peep in get_children():
		if peep is not Timer:
			peep.queue_free()
			peep_count -= 1

#func _draw() -> void:
	
	#for peep in peeps:
		#var frame_size = Vector2(16,21)
		#var frame_x = (peep.frame + 2) * frame_size.x
		#var frame_y = 1 * frame_size.y
		#var source_rect = Rect2(Vector2(frame_x, frame_y), frame_size)
		#var offset = Vector2(-frame_size.x * 0.5, -frame_size.y)
		#draw_texture_rect_region(peep_texture_body, Rect2(peep.global_position + offset, frame_size), source_rect, Color(1,1,1,1), false)
		#draw_texture_rect_region(peep_texture_head, Rect2(peep.global_position + offset, frame_size), source_rect, Color(1,1,1,1), false)
		
		
		
		
		
		#if peep.velocity.y > 0:
			#draw_texture_rect_region(peep_body_texture, )
			#draw_texture(peep_texture, peep.global_position)
		#elif peep.velocity.y < 0:
			#draw_texture(peep_texture, peep.global_position)
			#draw_texture(peep_texture, peep.global_position)
		#elif peep.velocity == Vector2.ZERO:
			#draw_texture(peep_texture, peep.global_position)
			#draw_texture(peep_texture, peep.global_position)
		
