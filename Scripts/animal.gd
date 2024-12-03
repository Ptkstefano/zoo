extends Node2D

class_name Animal

var animal_res : animal_resource

var base_speed : float
var run_speed : float

var speed

var id : int

enum ANIMAL_STATES {IDLE, WANDER, SWIMMING, MOVING_TOWARDS_REST, MOVING_TOWARDS_FOOD, EATING, RUNNING, RESTING}
var current_state = ANIMAL_STATES.IDLE

var move_states = [ANIMAL_STATES.WANDER, ANIMAL_STATES.SWIMMING, ANIMAL_STATES.MOVING_TOWARDS_FOOD, ANIMAL_STATES.MOVING_TOWARDS_REST, ANIMAL_STATES.RUNNING]
var fill_states = [ANIMAL_STATES.RUNNING, ANIMAL_STATES.EATING, ANIMAL_STATES.RESTING]

var animal_name
var animal_species : IdRefs.ANIMAL_SPECIES

var enclosure : Enclosure

var agent: NavigationAgent2D

var is_swimming : bool = false

## Variable used so that global position is not accessed on save-game
var cached_global_position : Vector2

var needs_rest : float = 70:
	set(value):
		needs_rest = clampf(value,0,100)
	
var needs_hunger : float = 70:
	set(value):
		needs_hunger = clampf(value,0,100)
		
var needs_play : float = 70:
	set(value):
		needs_play = clampf(value,0,100)

var hunger_restore_rate = 0.1
var rest_restore_rate = 0.01
var play_restore_rate = 0.05

var hunger_drain_rate = 0.8
var rest_drain_rate = 0.5
var play_drain_rate = 0.5

var preference_terrain_satisfied : bool
var preference_water_satisfied : bool
var preference_habitat_size_satisfied : bool
var preference_vegetation_coverage_satisfied : bool
var preference_herd_size_satisfied : bool
var preference_herd_density_satisfied : bool

var sprite_x : int = 0
var sprite_y : int = 0
var frame : int = 0

var direction : Vector2

@onready var screenNotifier = $VisibleOnScreenNotifier2D
@onready var animal_sprite = $Sprite2D

signal animal_removed

func _ready() -> void:
	agent = $NavigationAgent2D
	$StateTimer.timeout.connect(on_state_timer_timeout)
	$DecayTimer.timeout.connect(on_decay_timer_timeout)
	agent.set_target_position(get_new_destination())
	
	$FrameTimer.timeout.connect(on_frame_timer)
	
	$NoSwimTimer.timeout.connect(on_no_swim_timer_timeout)
	change_state(ANIMAL_STATES.IDLE)
	enclosure.enclosure_stats_updated.connect(update_habitat_satifaction)
	

func initialize_animal(res, coordinate, found_enclosure):
	
	animal_res = res
	
	$Sprite2D.texture = animal_res.texture
	$Shadow.scale = Vector2(animal_res.shadow_scale, animal_res.shadow_scale)
	base_speed = animal_res.base_speed
	run_speed = animal_res.run_speed
	
	$NavigationAgent2D.waypoint_reached.connect(on_agent_waypoint_reached)
	
	## Ensures sprite starts at origin
	$Sprite2D.offset = Vector2(0, (($Sprite2D.texture.get_height() * -0.25) + animal_res.sprite_y_offset))
	
	animal_name = animal_res.name
	animal_species = animal_res.species_id
	
	if animal_res.can_swim:
		$NavigationAgent2D.set_navigation_layer_value(2, false)
		$NavigationAgent2D.set_navigation_layer_value(3, true)
		
	if animal_res.species_id == IdRefs.ANIMAL_SPECIES.KARDOFAN_GIRAFFE:
		$NavigationAgent2D.target_desired_distance = 30
		
	global_position = coordinate
	cached_global_position = global_position
	enclosure = found_enclosure

func _physics_process(delta: float) -> void:
	#$Label.text = str(current_state)
	if screenNotifier.is_on_screen():
		z_index = Helpers.get_current_tile_z_index(global_position)
		animal_sprite.frame_coords = Vector2(sprite_x + frame, sprite_y)
		
	if current_state in fill_states:
		fill_needs(delta)

	if current_state in move_states:
		if $SwimRaycast.is_colliding():
			if !is_swimming:
				change_state(ANIMAL_STATES.SWIMMING)
		else:
			if is_swimming:
				on_swim_stop()
		if current_state == ANIMAL_STATES.RUNNING:
			speed = run_speed
		else:
			speed = base_speed

		if agent.is_navigation_finished():
			navigation_finished()

		move_toward_direction(direction, delta)
		update_frame_direction()
		
func get_new_destination():
	return TileMapRef.map_to_local(enclosure.enclosure_cells.pick_random())

func navigation_finished():
	if current_state == ANIMAL_STATES.RUNNING:
		agent.target_position=get_new_destination()
	if current_state == ANIMAL_STATES.MOVING_TOWARDS_FOOD:
		change_state(ANIMAL_STATES.EATING)
	if current_state == ANIMAL_STATES.WANDER:
		agent.target_position=get_new_destination()
	if current_state == ANIMAL_STATES.MOVING_TOWARDS_REST:
		change_state(ANIMAL_STATES.RESTING)


func on_state_timer_timeout():
	## Check for what animal wants to do, according to priorities.
	$StateTimer.start()
	if needs_hunger < 30:
		if is_instance_valid(enclosure.animal_feed):
			change_state(ANIMAL_STATES.MOVING_TOWARDS_FOOD)
			return
	if needs_rest < 30:
		change_state(ANIMAL_STATES.MOVING_TOWARDS_REST)
	elif needs_play < 75:
		change_state(ANIMAL_STATES.RUNNING)
	else:
		change_state(ANIMAL_STATES.IDLE)
	
	
func change_state(state : ANIMAL_STATES):
	current_state = state
	if state == ANIMAL_STATES.WANDER:
		$StateTimer.start()
		agent.target_position = get_new_destination()
		sprite_x = 2
	elif state == ANIMAL_STATES.SWIMMING:
		on_swim_start()
		sprite_x = 8
		agent.target_position=get_new_destination()
		$StateTimer.stop()
	elif state == ANIMAL_STATES.MOVING_TOWARDS_FOOD:
		speed = base_speed
		search_for_feed()
		sprite_x = 2
	elif state == ANIMAL_STATES.EATING:
		eat()
		$StateTimer.stop()
		sprite_x = 4
	elif state == ANIMAL_STATES.RESTING:
		$StateTimer.stop()
		$DecayTimer.stop()
		sprite_x = 6
	elif state == ANIMAL_STATES.RUNNING:
		speed = run_speed
		$StateTimer.stop()
		agent.target_position = get_new_destination()
		sprite_x = 2
	elif state == ANIMAL_STATES.MOVING_TOWARDS_REST:
		speed = base_speed
		search_for_rest()
		sprite_x = 2
	elif state == ANIMAL_STATES.IDLE:
		if $DecayTimer.is_stopped():
			$DecayTimer.start()
		if randi_range(0,100) > 75:
			change_state(ANIMAL_STATES.WANDER)
		else:
			$StateTimer.start()
			sprite_x = 0


func fill_needs(delta):
	if current_state == ANIMAL_STATES.EATING:
		needs_hunger += 2 * delta
		if needs_hunger > 90:
			change_state(ANIMAL_STATES.IDLE)
	elif current_state == ANIMAL_STATES.RESTING:
		sprite_x = 6
		needs_rest += 0.5 * delta
		if needs_rest > 90:
			change_state(ANIMAL_STATES.IDLE)
	elif current_state == ANIMAL_STATES.RUNNING:
		needs_play += 2 * delta
		if needs_play > 90:
			change_state(ANIMAL_STATES.IDLE)

func move_toward_direction(direction: Vector2, delta: float):
	global_position += direction * speed * delta

func on_agent_waypoint_reached(d):
	await get_tree().create_timer(0.05).timeout
	direction = (agent.get_next_path_position() - global_position).normalized()

func remove_animal():
	animal_removed.emit(self)
	queue_free()

func on_swim_start():
	is_swimming = true
	
func search_for_feed():
	if is_instance_valid(enclosure.animal_feed):
		agent.target_position = enclosure.animal_feed.global_position
	else:
		change_state(ANIMAL_STATES.IDLE)
		
func search_for_rest():
	if enclosure.available_shelters.size() > 0:
		var enclosure_shelters = enclosure.available_shelters
		var random_shelter = enclosure_shelters.pick_random()
		var random_resting_spot = random_shelter.rest_spots.pick_random()
		agent.target_position = random_resting_spot.global_position
	else:
		change_state(ANIMAL_STATES.RESTING)
	
func eat():
	if is_instance_valid(enclosure.animal_feed):
		enclosure.animal_feed.eat(10)
		$StateTimer.start()
		
		
func on_swim_stop():
	change_state(ANIMAL_STATES.IDLE)
	is_swimming = false
	$NavigationAgent2D.set_navigation_layer_value(3, false)
	$NavigationAgent2D.set_navigation_layer_value(2, true)
	$NoSwimTimer.start()
	
## Animal takes a break from swimming for a while
func on_no_swim_timer_timeout():
	$NavigationAgent2D.set_navigation_layer_value(3, true)
	$NavigationAgent2D.set_navigation_layer_value(2, false)
	
func on_decay_timer_timeout():
	needs_rest -= rest_drain_rate
	needs_hunger -= hunger_drain_rate
	needs_play -= play_drain_rate


func update_habitat_satifaction():
	preference_terrain_satisfied = true
	for key in animal_res.terrain_preference:
		if key in enclosure.terrain_coverage.keys():
			if enclosure.terrain_coverage[key] < animal_res.terrain_preference[key]:
				preference_terrain_satisfied = false
		else:
			preference_terrain_satisfied = false ## Missing required terrain
			
	if animal_res.needs_water:
		if enclosure.water_availability:
			preference_water_satisfied = true
		else:
			preference_water_satisfied = false
			
	if enclosure.enclosure_cells.size() > animal_res.minimum_habitat_size:
		preference_habitat_size_satisfied = true
	else:
		preference_habitat_size_satisfied = false

	if enclosure.vegetation_coverage > animal_res.minimum_vegetation_coverage and enclosure.vegetation_coverage < animal_res.maximum_vegetation_coverage:
		preference_vegetation_coverage_satisfied = true
	else:
		preference_vegetation_coverage_satisfied = false

	if enclosure.herd_size >= animal_res.minimum_herd_size:
		preference_herd_size_satisfied = true
	else:
		preference_herd_size_satisfied = false

	if enclosure.herd_density <= animal_res.maximum_herd_density:
		preference_herd_density_satisfied = true
	else:
		preference_herd_density_satisfied = false

func update_cached_position():
	cached_global_position = global_position

func on_frame_timer():
	if frame == 0:
		frame = 1
	else:
		frame = 0

func update_frame_direction():
	if direction.x > 0:
		animal_sprite.flip_h=true
	else:
		animal_sprite.flip_h=false
		
	if direction.y > 0:
		sprite_y = 1
	elif direction.y < 0:
		sprite_y = 0
