extends Node2D

@export var peep_scene : PackedScene

var speed := 20.0

var peep_manager : PeepManager

#@export var peep_texture : Texture2D

enum group_states {STOPPED, WALKING, OBSERVING, RESTING, USING_TOILET, GOING_TO_FOOD, GOING_TO_FIXTURE, GOING_TO_EXIT, GOING_TO_TOILET}

## move_states are processed into actual movement
var move_states : Array[group_states] = [group_states.WALKING, group_states.GOING_TO_FOOD, group_states.GOING_TO_FIXTURE, group_states.GOING_TO_EXIT, group_states.GOING_TO_TOILET]

## busy_states can't be overriden by another state
var busy_states : Array[group_states] = [group_states.GOING_TO_FOOD, group_states.GOING_TO_FIXTURE, group_states.GOING_TO_TOILET]

var group_state : group_states = group_states.WALKING

var peeps : Array[Peep] = []

var agent : NavigationAgent2D

var direction : Vector2

var group_desired_destinations = []
var group_desired_animals = [NameRefs.ANIMAL_SPECIES]
var desired_enclosures_id = []

var first_position_offset := Vector2(0, -5)
var second_position_offset := Vector2(-5, 0)
var third_position_offset := Vector2(5, 0)

var position_offsets = [Vector2(0, -7), Vector2(-7, 0), Vector2(7, 0), Vector2(0, 7), Vector2(0, 0)]

var observed_animals : Array[NameRefs.ANIMAL_SPECIES]
var favorite_animal : NameRefs.ANIMAL_SPECIES

var searching_rest_spot : bool = false
#var moving_towards_fixture : bool = false
var searching_food_spot : bool = false
#var moving_towards_food : bool = false
var searching_toilet : bool = false

var moving_towards_exit : bool = false

var fixture : Fixture = null
var fixture_available ## Dict or null

var shop : Shop = null
var visited_shops : Array[Shop] = []
var peep_group_inventory : Array[product_resource]

var modifiers = []

## Defines how tolerant peep group is to product's prices, higher is more exigent
var min_utility_score_tolerance : float

var zoo_rating_score : float = 3

var cached_position : Vector2

var z_index_value

signal peep_group_left



var needs_rest : float = 100:
	set(value):
		needs_rest = clamp(value,0,100)
		if value < 35:
			searching_rest_spot = true
		if needs_rest < 1:
			if !modifiers.has(ModifierManager.PEEP_MODIFIERS.NO_REST_SPOT):
				modifiers.append(ModifierManager.PEEP_MODIFIERS.NO_REST_SPOT)

var needs_hunger : float = 80:
	set(value):
		needs_hunger = clamp(value,0,100)
		if value < 35:
			searching_food_spot = true
		if needs_hunger < 1:
			if !modifiers.has(ModifierManager.PEEP_MODIFIERS.NO_FOOD):
				modifiers.append(ModifierManager.PEEP_MODIFIERS.NO_FOOD)
			
var needs_toilet : float = 35:
	set(value):
		needs_hunger = clamp(value,0,100)
		if value < 35:
			searching_toilet = true
		if needs_toilet < 1:
			if !modifiers.has(ModifierManager.PEEP_MODIFIERS.NO_TOILET):
				modifiers.append(ModifierManager.PEEP_MODIFIERS.NO_TOILET)
		
		
var hunger_drain_rate := 5.0
var rest_drain_rate := 8.0
var toilet_drain_rate := 5.0

var peep_count = null

@onready var screenNotifier = $VisibleOnScreenNotifier2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !peep_count:
		peep_count = randi_range(1,4)
	for i in range(peep_count):
		var peep = peep_scene.instantiate()
		peeps.append(peep)
		#peep_manager.peeps.append(peep)
		peep.position_offset = position_offsets[i]
		peep.global_position = global_position + position_offsets[i]
		$Peeps.add_child(peep)
	
	if !favorite_animal:
		favorite_animal = randi_range(0, NameRefs.ANIMAL_SPECIES.size() - 1)
	
	speed = randi_range(16, 24)
	
	agent = $NavigationAgent2D as NavigationAgent2D
	await get_tree().create_timer(0.5).timeout
	agent.path_desired_distance = randi_range(5, 20)
	
	min_utility_score_tolerance = randf_range(0.6, 1.5)
	
	agent.waypoint_reached.connect(on_agent_waypoint_reached)
	
	#$AnimalDetector.body_entered.connect(on_animal_detector_body_entered)
	#$FixtureDetector.area_entered.connect(on_fixture_detector_area_entered)
	#$GuestBuilding.area_entered.connect(on_guest_building_detector_area_entered)
	
	$Detector.area_entered.connect(on_detector_area_entered)
	$Detector.body_entered.connect(on_detector_body_entered)
	
	$StateTimer.timeout.connect(on_state_timer_timeout)
	$DecayTimer.timeout.connect(on_decay_timer_timeout)
	
	$VisibleOnScreenNotifier2D.screen_entered.connect(on_visibility_entered)
	
	initialize_peep_group_destinations()
	get_new_destination()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !screenNotifier.is_on_screen():
		for peep in peeps:
			peep.visible = false
		return
		
	#$Label.text = str(group_state)
	if group_state in move_states:
		move_toward_direction(direction, delta)
		z_index_value = Helpers.get_current_tile_z_index(global_position)
		for peep in peeps:
			peep.z_index = z_index_value
			peep.global_position = global_position + peep.position_offset
			peep.move_direction = direction
			
		if agent.is_navigation_finished():
			on_agent_target_reached()

func on_visibility_entered():
		for peep in peeps:
			peep.visible = true

func on_agent_waypoint_reached(d):
	await get_tree().create_timer(0.05).timeout
	direction = (agent.get_next_path_position() - global_position).normalized()
	
func on_agent_target_reached():
	if group_state == group_states.GOING_TO_FIXTURE:
		if fixture.type == NameRefs.FIXTURES.BENCH:
			change_state(group_states.RESTING)
	elif group_state == group_states.GOING_TO_FOOD:
		buy_food()
	elif group_state == group_states.GOING_TO_EXIT:
		leave_zoo()
	elif group_state == group_states.GOING_TO_TOILET:
		use_toilet()
	else:
		change_state(group_states.STOPPED)

func change_state(state):
	group_state = state
	if state == group_states.OBSERVING:
		$StateTimer.wait_time = 10
		$StateTimer.start()
		for peep in peeps:
			peep.change_state(state)
	elif state == group_states.WALKING:
		agent.target_position = group_desired_destinations.front().location
		direction = (agent.get_next_path_position() - global_position).normalized()
		for peep in peeps:
			peep.change_state(state)
	elif state == group_states.STOPPED:
		$StateTimer.wait_time = 5
		$StateTimer.start()
		for peep in peeps:
			peep.change_state(state)
	elif state == group_states.RESTING:
		needs_rest = 100
		$StateTimer.wait_time = 20
		$StateTimer.start()
		#global_position = fixture.global_position
		if !fixture_available:
			change_state(group_states.STOPPED)
			searching_rest_spot = true
			return
		for i in range(peep_count):
			if i == 0:
				peeps[0].change_state(3)
				peeps[0].global_position = fixture_available['p1']
				peeps[0].set_look_direction(fixture_available['dir'])
			elif i == 1:
				peeps[1].change_state(3)
				peeps[1].global_position = fixture_available['p2']
				peeps[1].set_look_direction(fixture_available['dir'])
			else:
				peeps[i].change_state(0)
	elif state == group_states.GOING_TO_FOOD:
		for peep in peeps:
			peep.change_state(1)
		return
	elif state == group_states.GOING_TO_FIXTURE:
		for peep in peeps:
			peep.change_state(1)
		return
	elif state == group_states.GOING_TO_TOILET:
		for peep in peeps:
			peep.change_state(1)
		return
	elif state == group_states.GOING_TO_EXIT:
		agent.target_position = Vector2(-1510,790)
		moving_towards_exit = true
		for peep in peeps:
			peep.change_state(1)

func get_new_destination():
	if moving_towards_exit:
		change_state(group_states.GOING_TO_EXIT)
		return
	if group_desired_destinations.is_empty():
		change_state(group_states.GOING_TO_EXIT)
		return
	else:
		change_state(group_states.WALKING)


func move_toward_direction(direction: Vector2, delta: float):
	global_position += direction * speed * delta
	
func on_detector_body_entered(body):
	if group_state in busy_states:
		return
	if body is Animal:
		if body.animal_species not in observed_animals:
			observed_animals.append(body.animal_species)
			change_state(group_states.OBSERVING)
			for peep in peeps:
				var dir = global_position.direction_to(body.global_position).angle()
				peep.look_direction = dir
		
		for destination in group_desired_destinations:
			if destination.especies == body.animal_res:
				group_desired_destinations.erase(destination)

func on_detector_area_entered(area):
	if group_state in busy_states:
		return
	if searching_rest_spot:
		if area.get_parent() is Fixture:
			fixture = area.get_parent()
			fixture_available = fixture.get_available()
			if !fixture_available:
				change_state(group_states.STOPPED)
				return
			if fixture.type == NameRefs.FIXTURES.BENCH:
				agent.target_position = fixture.global_position
				direction = (agent.get_next_path_position() - global_position).normalized()
				change_state(group_states.GOING_TO_FIXTURE)
				searching_rest_spot = false
	if searching_food_spot:
		if area.get_parent() is Shop:
			shop = area.get_parent()
			if shop in visited_shops:
				return
			if searching_food_spot:
				if NameRefs.PRODUCT_TYPES.FOOD in shop.product_types:
					agent.target_position = shop.sell_positions.pick_random()
					change_state(group_states.GOING_TO_FOOD)
	if searching_toilet:
		if area.get_parent() is Toilet:
			if searching_toilet:
				agent.target_position = area.get_parent().enter_positions.pick_random()
				change_state(group_states.GOING_TO_TOILET)


func on_state_timer_timeout():
	if group_state == group_states.OBSERVING:
		get_new_destination()
	if group_state == group_states.STOPPED:
		get_new_destination()
	if group_state == group_states.RESTING:
		fixture.make_available(fixture_available)
		get_new_destination()

func on_decay_timer_timeout():
	needs_rest -= rest_drain_rate
	needs_hunger -= hunger_drain_rate
	needs_toilet -= toilet_drain_rate

func buy_food():
	change_state(group_states.STOPPED)
	var available_items = {}
	## Fix bug if shop ceases to exist
	if !shop:
		return
	for item in shop.available_products:
		if item.type == NameRefs.PRODUCT_TYPES.FOOD:
			available_items[item] = item.perceived_value / item.current_cost
			
	var best_item = null
	var highest_utility = 0
	
	for item in available_items:
		var utility_score = available_items[item]
		if utility_score > highest_utility:
			highest_utility = utility_score
			#print('tolerance: ' + str(min_utility_score_tolerance), 'utility score:' + str(utility_score))
			if utility_score < min_utility_score_tolerance:
				continue
			else:
				best_item = item

	
	if best_item != null:
		## Buy
		shop.buy(best_item, peep_count)
		peep_group_inventory.append(best_item)
		needs_hunger = 100
		searching_food_spot = false
		if available_items[best_item] > 1.5:
			modifiers.append(ModifierManager.PEEP_MODIFIERS.GREAT_VALUE_FOOD)
	else:
		## Ensures peeps won't come back to this shop
		visited_shops.append(shop)
		modifiers.append(ModifierManager.PEEP_MODIFIERS.TOO_EXPENSIVE)
		#print("No adequately priced items available.")
		
	change_state(group_states.STOPPED)

func use_toilet():
	group_state = group_states.USING_TOILET
	for peep in peeps:
		peep.visible = false
	needs_toilet = 100
	await get_tree().create_timer(10).timeout
	for peep in peeps:
		peep.visible = true
	get_new_destination()

func initialize_peep_group_destinations():
	var keys = ZooManager.zoo_enclosures.keys()
	if keys.size() == 0:
		return
	
	if desired_enclosures_id.is_empty():
		## Generate random resired destinations
		for i in range(5):
			if keys.size() == 0:
				return
			var enclosure_key = keys.pick_random()
			keys.erase(enclosure_key)
			desired_enclosures_id.append(enclosure_key)
			group_desired_destinations.append(ZooManager.zoo_enclosures[enclosure_key])
			
	else:
		## Restore previously generated desired destinations
		for id in desired_enclosures_id:
			if id in ZooManager.zoo_enclosures.keys():
				group_desired_destinations.append(ZooManager.zoo_enclosures[id])
			
	## TODO - Sort group_desired_destinations
	
func leave_zoo():
	if group_desired_destinations.size() == 0 and observed_animals.size() > 2:
		modifiers.append(ModifierManager.PEEP_MODIFIERS.SEEN_ALL_DESIRED_ANIMALS)
	if group_desired_destinations.size() > 0:
		modifiers.append(ModifierManager.PEEP_MODIFIERS.MISSED_ANIMAL)
	if favorite_animal in observed_animals:
		modifiers.append(ModifierManager.PEEP_MODIFIERS.SEEN_FAVORITE_ANIMAL)
	if !modifiers.has(ModifierManager.PEEP_MODIFIERS.NO_TOILET) and !modifiers.has(ModifierManager.PEEP_MODIFIERS.NO_FOOD) and !modifiers.has(ModifierManager.PEEP_MODIFIERS.NO_REST_SPOT):
		modifiers.append(ModifierManager.PEEP_MODIFIERS.FILLED_NEEDS)
	var rating = calculate_perceived_zoo_rating()
	peep_group_left.emit(self, rating)

func update_cached_position():
	cached_position = global_position

func calculate_perceived_zoo_rating():
	var sum = 0
	for modifier in modifiers:
		sum += ModifierManager.peep_modifiers[modifier].point_value
	return clamp(zoo_rating_score + sum, 0, 5)
