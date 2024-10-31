extends CharacterBody2D

class_name Animal

var animal_res : animal_resource

var base_speed : float
var run_speed : float

var speed

enum ANIMAL_STATES {IDLE, MOVING_TOWARDS, EATING, RUNNING, RESTING}
var current_state = ANIMAL_STATES.IDLE
var next_state = null

var animal_name
var animal_species : NameRefs.ANIMAL_SPECIES

var enclosure : Enclosure

var agent: NavigationAgent2D

var is_swimming : bool = false

## Variable used so that global position is not accessed on save-game
var cached_global_position : Vector2

var needs_rest : float = 70:
	set(value):
		needs_rest = clamp(value,0,100)
	
var needs_hunger : float = 70:
	set(value):
		needs_hunger = clamp(value,0,100)
		
var needs_play : float = 70:
	set(value):
		needs_play = clamp(value,0,100)

var hunger_restore_rate = 0.1
var rest_restore_rate = 0.01
var play_restore_rate = 0.05

var hunger_drain_rate = 3.5
var rest_drain_rate = 2.5
var play_drain_rate = 5

var preference_terrain_satisfied : bool
var preference_water_satisfied : bool
var preference_habitat_size_satisfied : bool
var preference_vegetation_coverage_satisfied : bool
var preference_herd_size_satisfied : bool
var preference_herd_density_satisfied : bool

var direction = '_S'

signal animal_removed

func _ready() -> void:
	agent = $NavigationAgent2D
	$StateTimer.timeout.connect(on_state_timer_timeout)
	$DecayTimer.timeout.connect(on_decay_timer_timeout)
	agent.set_target_position(get_new_destination())
	#$SwimDetection.area_entered.connect(on_swim_start)
	#$SwimDetection.area_exited.connect(on_swim_stop)
	
	$NoSwimTimer.timeout.connect(on_no_swim_timer_timeout)
	$StateTimer.start()
	enclosure.enclosure_stats_updated.connect(update_habitat_satifaction)
	

func initialize_animal(res, coordinate, found_enclosure):
	
	animal_res = res
	
	$Sprite2D.texture = animal_res.texture
	$Shadow.scale = Vector2(animal_res.shadow_scale, animal_res.shadow_scale)
	base_speed = animal_res.base_speed
	run_speed = animal_res.run_speed
	
	$AnimationPlayer.speed_scale = animal_res.animation_speed_scale
	
	## Ensures sprite starts at origin
	$Sprite2D.offset = Vector2(0, (($Sprite2D.texture.get_height() * -0.25) + animal_res.sprite_y_offset))
	
	animal_name = animal_res.name
	animal_species = animal_res.species
	
	if animal_res.can_swim:
		$NavigationAgent2D.set_navigation_layer_value(2, false)
		$NavigationAgent2D.set_navigation_layer_value(3, true)
		
	global_position = coordinate
	cached_global_position = global_position
	enclosure = found_enclosure

func _physics_process(delta: float) -> void:
	z_index = Helpers.get_current_tile_z_index(global_position)
	play_animation()
	if current_state == ANIMAL_STATES.EATING:
		needs_hunger += hunger_restore_rate
		if needs_hunger > 90:
			on_state_timer_timeout()
	elif current_state == ANIMAL_STATES.RESTING:
		needs_rest += rest_restore_rate
		if needs_rest > 90:
			on_state_timer_timeout()
	elif current_state == ANIMAL_STATES.RUNNING or current_state == ANIMAL_STATES.MOVING_TOWARDS:
		if $SwimRaycast.is_colliding():
			if !is_swimming:
				on_swim_start(null)
		else:
			if is_swimming:
				on_swim_stop(null)
		if current_state == ANIMAL_STATES.RUNNING:
			needs_play += play_restore_rate
			speed = run_speed
		else:
			speed = base_speed
			
		if velocity.x > 0:
			$Sprite2D.flip_h=true
		else:
			$Sprite2D.flip_h=false
		if agent.is_navigation_finished():
			if current_state == ANIMAL_STATES.RUNNING:
				agent.target_position=get_new_destination()
			if current_state == ANIMAL_STATES.MOVING_TOWARDS:
				if !next_state:
					change_state('idle')
					$StateTimer.start()
				else:
					current_state = next_state
					next_state = null
		else:
			velocity = (agent.get_next_path_position() - global_position).normalized() * speed
			move_and_slide()
		
func get_new_destination():
	return TileMapRef.map_to_local(enclosure.enclosure_cells.pick_random())

func on_state_timer_timeout():
	## Check for what animal wants to do, according to priorities.
	if needs_hunger < 50:
		change_state('eat')
	elif needs_rest < 30:
		change_state('rest')
	elif needs_play < 75:
		change_state('play')
	else:
		change_state('idle')
	
	
func change_state(state):
	if is_swimming:
		current_state = ANIMAL_STATES.MOVING_TOWARDS
		agent.target_position=get_new_destination()
		$StateTimer.start()
		return
	if state == 'eat':
		current_state = ANIMAL_STATES.EATING
	if state == 'play':
		current_state = ANIMAL_STATES.RUNNING
		$StateTimer.start()
		get_new_destination()
	if state == 'rest':
		if enclosure.available_shelters.size() > 0:
			var enclosure_shelters = enclosure.available_shelters
			var random_shelter = enclosure_shelters.pick_random()
			var random_resting_spot = random_shelter.rest_spots.pick_random()
			
			agent.target_position = random_resting_spot.global_position
			next_state = ANIMAL_STATES.RESTING
			current_state = ANIMAL_STATES.MOVING_TOWARDS
		else:
			current_state = ANIMAL_STATES.RESTING
	if state == 'idle':
		if randi_range(0,100) > 75:
			$StateTimer.start()
			agent.target_position=get_new_destination()
			current_state = ANIMAL_STATES.MOVING_TOWARDS
		else:
			$StateTimer.start()
			current_state = ANIMAL_STATES.IDLE

func remove_animal():
	animal_removed.emit(self)
	queue_free()

func on_swim_start(area):
	print('swim')
	is_swimming = true
	
func on_swim_stop(area):
	if is_swimming:
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

func play_animation():
	if current_state == ANIMAL_STATES.RUNNING:
		$AnimationPlayer.speed_scale = animal_res.animation_speed_scale * 1.5
	else:
		$AnimationPlayer.speed_scale = animal_res.animation_speed_scale
	if velocity.y > 0:
		direction = '_S'
	elif  velocity.y < 0:
		direction = '_N'
	#else:
		#if randi_range(0,100) > 50:
			#direction = '_S'
		#else:
			#direction = '_N'
			
	if current_state == ANIMAL_STATES.MOVING_TOWARDS or current_state == ANIMAL_STATES.RUNNING:
		if velocity != Vector2.ZERO:
			if is_swimming:
				$AnimationPlayer.play('Swim'+direction)
			else:
				$AnimationPlayer.play('Walk'+direction)
	elif current_state == ANIMAL_STATES.RESTING:
		$AnimationPlayer.play('Rest'+direction)
	elif current_state == ANIMAL_STATES.IDLE:
		$AnimationPlayer.play('Idle'+direction)
	elif current_state == ANIMAL_STATES.EATING:
		$AnimationPlayer.play('Eat'+direction)

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
