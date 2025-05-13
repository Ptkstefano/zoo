extends Node2D

class_name PeepManager

@export var peep_scene : PackedScene
@export var peep_group_scene : PackedScene
var spawn_location : Vector2

var base_spawn_time : float = 8.0

@export var path_manager : PathManager

var peep_groups = []

var peep_count : int = 0:
	set(value):
		peep_count = value
		ZooManager.peep_count = value

var spawn_ratio

var attractiveness_multiplier = 10

@export var peep_texture_body : Texture2D
@export var peep_texture_head : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_location = path_manager.path_layer.map_to_local(Vector2(0,48))
	$PeepSpawnTimer.timeout.connect(on_peep_spawn_timeout)
	SignalBus.update_cached_positions.connect(update_peeps_cached_positions)
	SignalBus.debug_clear_peeps.connect(debug_clear_peeps)

	
func update_peeps_cached_positions():
	for group in peep_groups:
		if group:
			if is_instance_valid(group):
				group.update_cached_position()

func on_peep_spawn_timeout():
	if !ZooManager.zoo_entrance_open:
		%PeepSpawnTimer.wait_time = 2
		return
		
	## Controls flow of spawns
	if ZooManager.zoo_attractiveness == 0:
		return
	
	instantiate_peep_group(null)
	
	if peep_count == 0: 
		spawn_ratio = ZooManager.zoo_attractiveness
	else:
		spawn_ratio = (ZooManager.zoo_attractiveness * 0.5) / peep_count 
		
	spawn_ratio = clamp(spawn_ratio, 0.1, 10)
	
	if peep_count > (ZooManager.zoo_attractiveness):
		## Halves spawn of peeps
		spawn_ratio *= 0.5
		
	%PeepSpawnTimer.wait_time = base_spawn_time / spawn_ratio
	
	
func on_peep_group_left(group, rating):
	## TODO - update zoo status
	if rating >= 0:
		ZooManager.update_rating(rating)
		ZooManager.store_recent_peep_group_modifiers(group.thoughts)
		ZooManager.store_peep_group_review({'rating': rating, 'thoughts': group.thoughts})
		
	ZooManager.remove_peep_group_id(group.id)
	peep_count -= group.peep_count
	peep_groups.erase(group)
	group.queue_free()
	
func instantiate_peep_group(data):
	var new_peep_group = peep_group_scene.instantiate()
	if data:
		new_peep_group.load_data = data
	else:
		new_peep_group.global_position = spawn_location
		new_peep_group.id = ZooManager.generate_peep_group_id()
	new_peep_group.peep_manager = self
	add_child(new_peep_group)
	peep_groups.append(new_peep_group)
	new_peep_group.peep_group_left.connect(on_peep_group_left)
	new_peep_group.peep_count_added.connect(on_peep_count)
	
func on_peep_count(count):
	peep_count += count
	
func debug_clear_peeps():
	for peep_group in get_children():
		if peep_group is PeepGroup:
			peep_count -= peep_group.peep_count
			peep_group.queue_free()
			
func debug_hungry_peeps():
	for peep_group in get_children():
		if peep_group is PeepGroup:
			peep_group.needs_hunger = 10.0
			
func debug_toilet_peeps():
	for peep_group in get_children():
		if peep_group is PeepGroup:
			peep_group.needs_toilet = 10.0
