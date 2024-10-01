extends Node2D

@export var peep_scene : PackedScene

const SPEED = 20.0

var peep_manager : PeepManager

@export var peep_texture : Texture2D

var peeps = []

var agent 

var first_position_offset = Vector2(0, -5)
var second_position_offset = Vector2(-5, 0)
var third_position_offset = Vector2(5, 0)

var position_offsets = [Vector2(0, -7), Vector2(-7, 0), Vector2(7, 0), Vector2(-7, 0), Vector2(0, 0)]

var peep_count = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	peep_count = randi_range(1,5)
	for i in range(peep_count):
		var peep = peep_scene.instantiate()
		peeps.append(peep)
		peep_manager.peeps.append(peep)
		peep.position_offset = position_offsets[i]
		peep.global_position = global_position + position_offsets[i]
		$Peeps.add_child(peep)
	
	agent = $NavigationAgent2D
	await get_tree().create_timer(0.5).timeout
	get_new_destination()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_toward_position(agent.get_next_path_position(), delta)
	if agent.is_navigation_finished():
		get_new_destination()
	
	for peep in peeps:
		peep.group_position = global_position
	

func get_new_destination():
	var destination = peep_manager.generate_peep_destination()
	agent.target_position=destination

func move_toward_position(destination: Vector2, delta: float):
	var direction = (destination - global_position).normalized()
	global_position += direction * SPEED * delta
