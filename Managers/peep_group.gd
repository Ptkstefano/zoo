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

var searching_rest_spot : bool = false
var moving_towards_fixture : bool = false

var searching_food_spot : bool = false
var moving_towards_food : bool = false

var fixture = null
var fixture_available

var shop = null
var visited_shops = []
var peep_group_inventory : Array[product_resource]

## Defines how tolerant peep group is to product's prices
var utility_score_tolerance : float



var needs_rest : float = 100:
	set(value):
		needs_rest = clamp(value,0,100)
		if value < 35:
			searching_rest_spot = true

var needs_hunger : float = 80:
	set(value):
		needs_hunger = clamp(value,0,100)
		if value < 35:
			searching_food_spot = true
		
		
var hunger_drain_rate = 0.5
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
	
	agent = $NavigationAgent2D as NavigationAgent2D
	await get_tree().create_timer(0.5).timeout
	
	utility_score_tolerance = randf_range(0.6, 1.2)
	
	agent.waypoint_reached.connect(on_agent_waypoint_reached)
	
	$AnimalDetector.body_entered.connect(on_animal_detector_body_entered)
	$FixtureDetector.area_entered.connect(on_fixture_detector_area_entered)
	$ShopDetector.area_entered.connect(on_shop_detector_area_entered)
	$StateTimer.timeout.connect(on_state_timer_timeout)
	$DecayTimer.timeout.connect(on_decay_timer_timeout)
	
	get_new_destination()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if group_state == group_states.WALKING:
		move_toward_direction(direction, delta)
		for peep in peeps:
			peep.group_position = global_position
			
		if agent.is_navigation_finished():
			on_agent_target_reached()

func on_agent_waypoint_reached(d):
	await get_tree().create_timer(0.05).timeout
	direction = (agent.get_next_path_position() - global_position).normalized()
	#if agent.is_navigation_finished():
		#on_agent_target_reached()
	
func on_agent_target_reached():
	if moving_towards_fixture:
		if fixture.type == NameRefs.FIXTURES.BENCH:
			change_state(group_states.RESTING)
	if moving_towards_food:
		buy_food()
	else:
		change_state(group_states.STOPPED)

func change_state(state):
	if state == group_states.OBSERVING:
		$StateTimer.wait_time = 10
		$StateTimer.start()
		group_state = state
		for peep in peeps:
			peep.change_state(state)
	if state == group_states.WALKING:
		get_new_destination()
		group_state = state
		for peep in peeps:
			peep.change_state(state)
	if state == group_states.STOPPED:
		$StateTimer.wait_time = 5
		$StateTimer.start()
		group_state = state
		for peep in peeps:
			peep.change_state(state)
	if state == group_states.RESTING:
		needs_rest = 100
		$StateTimer.wait_time = 20
		$StateTimer.start()
		group_state = state
		global_position = fixture.global_position
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
			#else:
				#peeps[i].change_state(0)

func get_new_destination():
	var destination = peep_manager.generate_peep_destination()
	agent.target_position=destination
	direction = (agent.get_next_path_position() - global_position).normalized()

func move_toward_direction(direction: Vector2, delta: float):
	global_position += direction * SPEED * delta

func on_animal_detector_body_entered(body):
	if body is Animal:
		if body.animal_species not in observed_animals:
			observed_animals.append(body.animal_species)
			change_state(group_states.OBSERVING)
			for peep in peeps:
				var dir = global_position.direction_to(body.global_position).angle()
				peep.look_direction = dir

func on_fixture_detector_area_entered(area):
	if searching_rest_spot:
		fixture = area.get_parent()
		fixture_available = fixture.get_available()
		if !fixture_available:
			change_state(group_states.STOPPED)
			return
		if fixture.type == NameRefs.FIXTURES.BENCH:
			agent.target_position = fixture.global_position
			direction = (agent.get_next_path_position() - global_position).normalized()
			moving_towards_fixture = true
			searching_rest_spot = false
			
func on_shop_detector_area_entered(area):
	shop = area.get_parent()
	if shop in visited_shops:
		return
	if searching_food_spot:
		if NameRefs.PRODUCT_TYPES.FOOD in shop.product_types:
			agent.target_position = shop.sell_positions.pick_random()
			moving_towards_food = true

func on_state_timer_timeout():
	if group_state == group_states.OBSERVING:
		change_state(group_states.WALKING)
	if group_state == group_states.STOPPED:
		change_state(group_states.WALKING)
	if group_state == group_states.RESTING:
		fixture.make_available(fixture_available)
		change_state(group_states.WALKING)
		moving_towards_fixture = false

func on_decay_timer_timeout():
	needs_rest -= rest_drain_rate
	needs_hunger -= hunger_drain_rate

func buy_food():
	moving_towards_food = false
	var available_items = {}
	for item in shop.available_products:
		if item.type == NameRefs.PRODUCT_TYPES.FOOD:
			available_items[item] = item.perceived_value / item.current_cost
			
	var best_item = null
	var highest_utility = 0
	
	for item in available_items:
		var utility_score = available_items[item]
		if utility_score > highest_utility:
			highest_utility = utility_score
			if utility_score < utility_score_tolerance:
				continue
			else:
				best_item = item
	
	if best_item != null:
		## Buy
		shop.buy(best_item, peep_count)
		peep_group_inventory.append(best_item)
		needs_hunger = 100
		searching_food_spot = false
	else:
		## Ensures peeps won't come back to this shop
		visited_shops.append(shop)
		print("No adequately priced items available.")
		
	change_state(group_states.STOPPED)
