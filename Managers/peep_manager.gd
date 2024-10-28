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
	
func update_peeps_cached_positions():
	for group in peep_groups:
		group.update_cached_position()

func on_peep_spawn_timeout():
	instantiate_peep_group(null)
	
func on_peep_group_left(group):
	## TODO - update zoo status
	peep_count -= group.peep_count
	peep_groups.erase(group)
	group.queue_free()

func instantiate_peep_group(data):
	var new_peep_group = peep_group_scene.instantiate()
	if data:
		new_peep_group.global_position = data.spawn_location
		new_peep_group.needs_rest = data.needs_rest
		new_peep_group.needs_hunger = data.needs_hunger
		new_peep_group.needs_toilet  = data.needs_toilet
		new_peep_group.desired_destinations_id = data.desired_destinations_id
		for animal in data.observed_animals:
			new_peep_group.observed_animals.append(animal)
		new_peep_group.peep_count = data.peep_count
	else:
		new_peep_group.global_position = spawn_location
	new_peep_group.peep_manager = self
	add_child(new_peep_group)
	peep_groups.append(new_peep_group)
	new_peep_group.peep_group_left.connect(on_peep_group_left)
	peep_count += new_peep_group.peep_count

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
		
