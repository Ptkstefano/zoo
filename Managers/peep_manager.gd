extends Node2D

class_name PeepManager

@export var peep_scene : PackedScene
@export var peep_group_scene : PackedScene
var spawn_location : Vector2

var base_spawn_time : float = 7.0

@export var path_manager : PathManager

var peep_groups = []

var peep_count : int = 0

@export var peep_texture_body : Texture2D
@export var peep_texture_head : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_location = path_manager.path_layer.map_to_local(Vector2(0,48))
	$PeepSpawnTimer.timeout.connect(on_peep_spawn_timeout)

	
func update_peeps_cached_positions():
	for group in peep_groups:
		if group:
			group.update_cached_position()

func on_peep_spawn_timeout():
	## Controls flow of spawns
	if ZooManager.zoo_attractiveness == 0:
		return
	
	if peep_count > ZooManager.zoo_attractiveness:
		return
		
	instantiate_peep_group(null)
	
	var ratio = ZooManager.zoo_attractiveness / peep_count
	%PeepSpawnTimer.wait_time = base_spawn_time / ratio
	
	
func on_peep_group_left(group, rating):
	## TODO - update zoo status
	ZooManager.update_rating(rating)
	DataManager.add_peep_group_modifiers(group.modifiers)
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
		new_peep_group.desired_enclosures_id = data.desired_destinations_id
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
