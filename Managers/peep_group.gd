extends Node2D

@export var peep_scene : PackedScene

const SPEED = 20.0

var peep_manager : PeepManager

#@export var peep_texture : Texture2D

enum group_states {STOPPED, WALKING, OBSERVING, RESTING}

var group_state : group_states = group_states.WALKING

var peeps = []

var agent 

var direction : Vector2

var first_position_offset = Vector2(0, -5)
var second_position_offset = Vector2(-5, 0)
var third_position_offset = Vector2(5, 0)

var position_offsets = [Vector2(0, -7), Vector2(-7, 0), Vector2(7, 0), Vector2(0, 7), Vector2(0, 0)]

var observed_animals : Array[NameRefs.ANIMAL_SPECIES]

var needs_rest : float = 90:
	set(value):
		needs_rest = clamp(value,0,100)

var needs_hunger : float = 90:
	set(value):
		needs_hunger = clamp(value,0,100)
		
		
var hunger_drain_rate = 1
var rest_drain_rate = 1

var peep_count = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	peep_count = randi_range(1,4)
	for i in range(peep_count):
		var peep = peep_scene.instantiate()
		peeps.append(peep)
		peep_manager.peeps.append(peep)
		peep.position_offset = position_offsets[i]
		peep.global_position = global_position + position_offsets[i]
		$Peeps.add_child(peep)
	
	agent = $NavigationAgent2D
	await get_tree().create_timer(0.5).timeout
	
	agent.waypoint_reached.connect(on_agent_waypoint_reached)
	
	$AnimalDetector.body_entered.connect(on_detector_body_entered)
	$StateTimer.timeout.connect(on_state_timer_timeout)
	$DecayTimer.timeout.connect(on_decay_timer_timeout)
	
	get_new_destination()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if group_state == group_states.WALKING:
		move_toward_direction(direction, delta)
		if agent.is_navigation_finished():
			change_state(group_states.STOPPED)
		
		for peep in peeps:
			peep.group_position = global_position

func on_agent_waypoint_reached(d):
	await get_tree().create_timer(0.01).timeout
	direction = (agent.get_next_path_position() - global_position).normalized()

func change_state(state):
	if state == group_states.OBSERVING:
		$StateTimer.wait_time = 10
		$StateTimer.start()
	if state == group_states.WALKING:
		get_new_destination()
	if state == group_states.STOPPED:
		$StateTimer.wait_time = 5
		$StateTimer.start()
		
	group_state = state
	for peep in peeps:
		peep.change_state(state)
		

func get_new_destination():
	var destination = peep_manager.generate_peep_destination()
	agent.target_position=destination
	direction = (agent.get_next_path_position() - global_position).normalized()

func move_toward_direction(direction: Vector2, delta: float):
	global_position += direction * SPEED * delta

func on_detector_body_entered(body):
	if body is Animal:
		if body.animal_species not in observed_animals:
			observed_animals.append(body.animal_species)
			change_state(group_states.OBSERVING)
			for peep in peeps:
				var dir = global_position.direction_to(body.global_position).angle()
				print(dir)
				peep.look_direction = dir

func on_state_timer_timeout():
	if group_state == group_states.OBSERVING:
		change_state(group_states.WALKING)
	if group_state == group_states.STOPPED:
		change_state(group_states.WALKING)

func on_decay_timer_timeout():
	needs_rest -= rest_drain_rate
	needs_hunger -= hunger_drain_rate
