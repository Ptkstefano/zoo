extends Node2D

class_name Animal

@export var happy_smile : Texture
@export var bad_smile : Texture
@export var heart : Texture
@export var dead_icon : Texture

var animal_res : animal_resource

var base_speed : float
var run_speed : float

var speed

var id : int

enum ANIMAL_STATES {IDLE, WANDER, SWIMMING, MOVING_TOWARDS_REST, MOVING_TOWARDS_FOOD, MOVING_TOWARDS_MATE, EATING, RUNNING, RESTING, WAITING, MATING, DEAD, INSIDE_SHELTER}
var current_state = ANIMAL_STATES.IDLE

var move_states = [ANIMAL_STATES.WANDER, ANIMAL_STATES.SWIMMING, ANIMAL_STATES.MOVING_TOWARDS_FOOD, ANIMAL_STATES.MOVING_TOWARDS_REST, ANIMAL_STATES.MOVING_TOWARDS_MATE, ANIMAL_STATES.RUNNING]
var fill_states = [ANIMAL_STATES.RUNNING, ANIMAL_STATES.EATING, ANIMAL_STATES.RESTING]

var animal_name : String
var animal_species : IdRefs.ANIMAL_SPECIES

var animal_gender : IdRefs.ANIMAL_GENDERS = 0
var is_animal_pregnant : bool = false
var months_pregnant : int = 0

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

var target_shelter

var animal_happiness : float = 2.5:
	set(value):
		animal_happiness = clampf(value, 0, 5)
		
var habitat_happiness : float = 0:
	set(value):
		habitat_happiness = clampf(value, 0, 5)
		
var preference_terrain_satisfied : bool
var lacking_terrain_types = []
var preference_water_satisfied : bool
var preference_habitat_size_satisfied : bool
var preference_vegetation_coverage_satisfied : bool
var too_much_vegetation : bool = false
var too_little_vegetation : bool = false
var preference_herd_size_satisfied : bool
var preference_herd_density_satisfied : bool
var favorite_tree_satisfied : bool
var is_there_disliked_terrain : bool = false
var disliked_terrains_in_habitat = []

var sprite_x : int = 0
var sprite_y : int = 0
var frame : int = 0

var animal_color_variation : int = 1

var base_sprite_y : int = 0

var is_infant : bool = false
var is_looking_for_mate : bool = false
var months_of_life : int
var months_in_zoo : int = 0
var is_dead : bool = false
var is_inside_shelter : bool = false

var sprite_x_size : int
var sprite_y_size : int

var found_mate : Animal

var direction : Vector2

@onready var screenNotifier = $VisibleOnScreenNotifier2D
@onready var animal_sprite = $Sprite2D

signal spawn_cub
signal animal_removed

func _ready() -> void:
	agent = $NavigationAgent2D
	$StateTimer.timeout.connect(on_state_timer_timeout)
	$DecayTimer.timeout.connect(on_decay_timer_timeout)
	agent.set_target_position(get_new_destination())
	
	$FrameTimer.timeout.connect(on_frame_timer)
	
	$NoSwimTimer.timeout.connect(on_no_swim_timer_timeout)
	
	TimeManager.on_pass_month.connect(on_month_pass)
	
	change_state(ANIMAL_STATES.IDLE)
	enclosure.enclosure_stats_updated.connect(update_habitat_satifaction)
	
	SignalBus.update_cached_positions.connect(update_cached_position)
	

func initialize_animal(res, coordinate, found_enclosure, saved_data, is_spawned_infant, spawn_gender):
	
	animal_res = res
	
	if saved_data:
		animal_gender = saved_data['animal_gender']
		needs_rest = saved_data['needs_rest']
		needs_hunger = saved_data['needs_hunger']
		needs_play = saved_data['needs_play']
		is_animal_pregnant = saved_data['is_animal_pregnant']
		months_pregnant = saved_data['months_pregnant']
		is_looking_for_mate = saved_data['is_looking_for_mate']
		is_infant = saved_data['is_infant']
		animal_color_variation = saved_data['animal_color_variation']
		months_of_life = saved_data.get('months_of_life', 20)
		months_in_zoo = saved_data.get('months_in_zoo', 0)
		is_dead = saved_data.get('is_dead', false)
		
	else:
		animal_color_variation = (randi_range(1, animal_res.possible_sprite_variations))
		if is_spawned_infant:
			is_infant = true
			animal_gender = [IdRefs.ANIMAL_GENDERS.MALE, IdRefs.ANIMAL_GENDERS.FEMALE].pick_random()
			months_of_life = 0
			if animal_res.can_be_albino:
				if randi_range(0, 100) > 95:
					## Spawn random albino animal
					animal_color_variation = animal_res.possible_sprite_variations + 1
		else:
			animal_gender = spawn_gender
			months_of_life = animal_res.months_to_adulthood + int((randf_range(0.05, 0.3) * animal_res.months_of_expected_lifetime))
	
	if !is_infant:
		$Sprite2D.texture = animal_res.texture
	else:
		$Sprite2D.texture = animal_res.cub_texture
		
	$Shadow.scale = Vector2(animal_res.shadow_scale, animal_res.shadow_scale)
	base_speed = animal_res.base_speed
	run_speed = animal_res.run_speed
	
	$NavigationAgent2D.waypoint_reached.connect(on_agent_waypoint_reached)
	
	$Sprite2D.vframes = 2 * animal_res.possible_sprite_variations
	
	if animal_res.can_be_albino:
		$Sprite2D.vframes += 2

	if animal_res.separate_gender_sprites:
		$Sprite2D.vframes *= 2
		
	$Sprite2D.offset = Vector2(0, ((int(($Sprite2D.texture.get_height() / ($Sprite2D.vframes))) * -0.5) + animal_res.sprite_y_offset))
	
	if animal_res.separate_gender_sprites:
		if animal_gender == IdRefs.ANIMAL_GENDERS.MALE:
			base_sprite_y =  ((animal_color_variation - 1) * 4)
		else:
			base_sprite_y =  ((animal_color_variation - 1) * 4) + 2
	else:
		base_sprite_y =  (animal_color_variation - 1) * 2
	animal_name = animal_res.name
	animal_species = animal_res.species_id
	
	$Sprite2D.frame_coords = Vector2i(0, base_sprite_y)
	
	if animal_res.can_swim:
		$NavigationAgent2D.set_navigation_layer_value(2, false)
		$NavigationAgent2D.set_navigation_layer_value(3, true)
	else:
		$NavigationAgent2D.set_navigation_layer_value(2, true)
		$NavigationAgent2D.set_navigation_layer_value(3, false)
		$SwimRaycast.enabled = false
		
	if animal_res.species_id == IdRefs.ANIMAL_SPECIES.KARDOFAN_GIRAFFE:
		$NavigationAgent2D.target_desired_distance = 30
		
	global_position = coordinate
	cached_global_position = Vector2(global_position.x, global_position.y)
	enclosure = found_enclosure
	
	sprite_x_size = animal_res.texture.get_width() / $Sprite2D.hframes
	sprite_y_size = animal_res.texture.get_height() / 2

func _physics_process(delta: float) -> void:
	#$Label.text = str(current_state)
	if is_dead:
		return
	
	if screenNotifier.is_on_screen():
		animal_sprite.frame_coords = Vector2(sprite_x + frame, sprite_y)
		
	if current_state in fill_states:
		fill_needs(delta)

	if current_state in move_states:
		z_index = Helpers.get_current_tile_z_index(global_position)
		if animal_res.can_swim:
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
	if !is_instance_valid(enclosure):
		remove_animal()
		return
	return TileMapRef.map_to_local(enclosure.enclosure_cells.pick_random())

func navigation_finished():
	if current_state == ANIMAL_STATES.RUNNING:
		agent.target_position = get_new_destination()
	if current_state == ANIMAL_STATES.MOVING_TOWARDS_FOOD:
		change_state(ANIMAL_STATES.EATING)
	if current_state == ANIMAL_STATES.WANDER:
		agent.target_position=get_new_destination()
	if current_state == ANIMAL_STATES.MOVING_TOWARDS_REST:
		if target_shelter.is_entereable:
			print('leap towards')
			on_leap_towards(target_shelter.rest_spots.pick_random().global_position, true)
		else:
			change_state(ANIMAL_STATES.RESTING)
	if current_state == ANIMAL_STATES.SWIMMING:
		agent.target_position=get_new_destination()
	if current_state == ANIMAL_STATES.MOVING_TOWARDS_MATE:
		found_mate.change_state(ANIMAL_STATES.MATING)
		change_state(ANIMAL_STATES.MATING)
		is_looking_for_mate = false
		found_mate = null
		

func on_state_timer_timeout():
	## Check for what animal wants to do, according to priorities.
	$StateTimer.start()
	if current_state == ANIMAL_STATES.MATING:
		change_state(ANIMAL_STATES.IDLE)
		if animal_gender == IdRefs.ANIMAL_GENDERS.FEMALE:
			is_animal_pregnant = true
	if needs_hunger < 30:
		if is_instance_valid(enclosure.animal_feed):
			change_state(ANIMAL_STATES.MOVING_TOWARDS_FOOD)
			return
	if needs_rest < 30:
		change_state(ANIMAL_STATES.MOVING_TOWARDS_REST)
	elif needs_play < 75:
		change_state(ANIMAL_STATES.RUNNING)
	elif is_looking_for_mate:
		look_for_mate()
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
		#agent.target_position=get_new_destination()
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
	elif state == ANIMAL_STATES.MOVING_TOWARDS_MATE:
		$StateTimer.stop()
		$DecayTimer.stop()
		sprite_x = 2
	elif state == ANIMAL_STATES.MOVING_TOWARDS_REST:
		$StateTimer.stop()
		speed = base_speed
		search_for_rest()
		sprite_x = 2
	elif state == ANIMAL_STATES.MATING:
		mate()
		$StateTimer.start()
		sprite_x = 0
	elif state == ANIMAL_STATES.WAITING:
		$StateTimer.stop()
		$DecayTimer.stop()
		sprite_x = 0
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
			if is_inside_shelter:
				on_leap_towards(target_shelter.entrance_pos, false)
			else:
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

func set_direction(global_pos):
	direction = (global_pos - global_position).normalized()

func remove_animal():
	animal_removed.emit(self) ## Get's sent to enclosure and animal manager

func on_swim_start():
	is_swimming = true
	
func search_for_feed():
	if is_instance_valid(enclosure.animal_feed):
		agent.target_position = enclosure.animal_feed.global_position
	else:
		enclosure.add_to_work_queue()
		change_state(ANIMAL_STATES.IDLE)
		
func search_for_rest():
	print('looking for rest')
	if enclosure.available_shelters.size() > 0:
		var enclosure_shelters = enclosure.available_shelters
		target_shelter = enclosure_shelters.pick_random()
		if target_shelter.is_entereable:
			agent.target_position = target_shelter.entrance_pos
		else:
			var random_resting_spot = target_shelter.rest_spots.pick_random()
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
	var previous_happiness = habitat_happiness
	var habitat_happiness_value = 0
	lacking_terrain_types.clear()
	preference_terrain_satisfied = true
	is_there_disliked_terrain = false
	for key in animal_res.terrain_preference:
		if key in enclosure.terrain_coverage.keys():
			if enclosure.terrain_coverage[key] < animal_res.terrain_preference[key]:
				preference_terrain_satisfied = false
				habitat_happiness_value -= 0.25
				lacking_terrain_types.append(int(key))
		else:
			preference_terrain_satisfied = false ## Missing required terrain
			habitat_happiness_value -= 0.25
			
	disliked_terrains_in_habitat.clear()
	for key in animal_res.terrain_dislike:
		if key in enclosure.terrain_coverage.keys():
			disliked_terrains_in_habitat.append(key)
			is_there_disliked_terrain = true
			preference_terrain_satisfied = false ## Missing required terrain
			habitat_happiness_value -= 0.25
			
	if animal_res.needs_water:
		if enclosure.water_availability:
			preference_water_satisfied = true
		else:
			preference_water_satisfied = false
			habitat_happiness_value -= 0.5
			
	if enclosure.enclosure_cells.size() > animal_res.minimum_habitat_size + (enclosure.enclosure_animals.size() * animal_res.minimum_cells_per_animal):
		preference_habitat_size_satisfied = true
		habitat_happiness_value += 1
	else:
		preference_habitat_size_satisfied = false

	if enclosure.vegetation_coverage > animal_res.minimum_vegetation_coverage and enclosure.vegetation_coverage < animal_res.maximum_vegetation_coverage:
		preference_vegetation_coverage_satisfied = true
		too_little_vegetation = false
		too_much_vegetation = false
		habitat_happiness_value += 1
	else:
		preference_vegetation_coverage_satisfied = false
		if enclosure.vegetation_coverage < animal_res.minimum_vegetation_coverage:
			too_little_vegetation = true
			too_much_vegetation = false
		else:
			too_much_vegetation = true
			too_little_vegetation = false

	if enclosure.herd_size >= animal_res.minimum_herd_size:
		preference_herd_size_satisfied = true
		habitat_happiness_value += 1
	else:
		preference_herd_size_satisfied = false

	if enclosure.cells_per_animal >= animal_res.minimum_cells_per_animal:
		preference_herd_density_satisfied = true
		habitat_happiness_value += 1
	else:
		preference_herd_density_satisfied = false
		
	if enclosure.enclosure_tree_species_ids.has(animal_res.favorite_tree):
		favorite_tree_satisfied = true
		habitat_happiness_value += 1
	else:
		favorite_tree_satisfied = false
		
	habitat_happiness = habitat_happiness_value
	
	if habitat_happiness_value > previous_happiness:
		spawn_smile(happy_smile)
	elif habitat_happiness_value < previous_happiness:
		spawn_smile(bad_smile)
		

func update_cached_position():
	cached_global_position = Vector2(global_position.x, global_position.y)

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
		sprite_y = base_sprite_y + 1
	elif direction.y < 0:
		sprite_y = base_sprite_y

func spawn_smile(texture):
	if !GameManager.game_running:
		return

	$HappinessSmile.texture = texture
	$HappinessSmile.show()
	$HappinessSmile.modulate = Color.WHITE
	
	var y_offset = sprite_y_size * 0.8
	#var x_offset = sprite_x_size * 0.1
	
	if animal_sprite.flip_h:
		$HappinessSmile.position = Vector2(0, -10 - y_offset)
	else:
		$HappinessSmile.position = Vector2(0, -10 - y_offset)
	
	await get_tree().create_timer(0.5).timeout
	
	var tween = create_tween()
	tween.tween_property($HappinessSmile, "position", Vector2($HappinessSmile.position.x, $HappinessSmile.position.y - 10), 1).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property($HappinessSmile, "modulate", Color('#ffffff00'), 0.5)
	await tween.finished
	$HappinessSmile.hide()

func check_if_wants_to_mate():
	if habitat_happiness == 5:
		if randi_range(0, 100) > (100 - animal_res.percentage_of_will_to_mate):
			is_looking_for_mate = true
	else:
		is_looking_for_mate = false

func on_month_pass():
	months_of_life += 1
	months_in_zoo += 1
	
	if months_of_life > animal_res.months_of_expected_lifetime:
		if randi_range(0,100) > 70:
			die()
	
	if is_infant:
		if months_of_life >= animal_res.months_to_adulthood:
			grow_up()
	
	if is_animal_pregnant:
		months_pregnant += 1
	else:
		check_if_wants_to_mate()
		
	if months_pregnant >= animal_res.months_of_pregnancy:
		give_birth()

	
	
func look_for_mate():
	found_mate = enclosure.find_mate_for_animal(self)
	if found_mate:
		agent.target_position = found_mate.global_position
		found_mate.wait_for_mate(self)
		change_state(ANIMAL_STATES.MOVING_TOWARDS_MATE)
	else:
		return false
	
func wait_for_mate(animal):
	found_mate = animal
	change_state(ANIMAL_STATES.WAITING)

func give_birth():
	spawn_smile(heart)
	spawn_cub.emit(self)
	months_pregnant = 0
	is_animal_pregnant = false
	return

func grow_up():
	Effects.wobble(self)
	is_infant = false
	$Sprite2D.texture = animal_res.texture

func mate():
	spawn_smile(heart)
	is_looking_for_mate = false

func die():
	## As of now, infants can't die
	if is_infant:
		return
	if current_state == ANIMAL_STATES.SWIMMING:
		return
	current_state == ANIMAL_STATES.DEAD
	animal_sprite.frame_coords = Vector2(10, sprite_y)
	is_dead = true
	enclosure.add_dead_animal(self)
	$StateTimer.stop()
	$DecayTimer.stop()
	$FrameTimer.stop()
	
	$HappinessSmile.texture = dead_icon
	$HappinessSmile.show()
	$HappinessSmile.modulate = Color.WHITE
	
	$HappinessSmile.position = Vector2(0, -sprite_y_size * 0.5)
	
	
func debug_toggle_pathfinding_draw():
	if !agent.get_debug_enabled():
		agent.set_debug_enabled(true)
	else:
		agent.set_debug_enabled(false)


func on_leap_towards(final_pos, is_entering_shelter):
	if is_entering_shelter:
		## Setting to idle so that z_index is not overriden
		current_state = ANIMAL_STATES.IDLE
		z_index = target_shelter.shelter_interior_z_index
		var tween = get_tree().create_tween()
		sprite_x = 2
		direction = global_position.direction_to(final_pos)
		var duration = global_position.distance_to(final_pos) / base_speed
		tween.tween_property(self, "global_position", final_pos, duration).set_trans(Tween.TRANS_LINEAR)
		await get_tree().create_timer(duration).timeout
		change_state(ANIMAL_STATES.RESTING)
		is_inside_shelter = true
	else:
		## Setting to idle so that z_index is not overriden
		current_state = ANIMAL_STATES.IDLE
		var tween = get_tree().create_tween()
		sprite_x = 2
		direction = global_position.direction_to(final_pos)
		var duration = global_position.distance_to(final_pos) / base_speed
		tween.tween_property(self, "global_position", final_pos, duration).set_trans(Tween.TRANS_LINEAR)
		await get_tree().create_timer(duration).timeout
		sprite_x = 0
		change_state(ANIMAL_STATES.IDLE)
