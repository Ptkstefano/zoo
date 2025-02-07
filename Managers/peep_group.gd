extends Node2D
class_name PeepGroup

@export var peep_scene : PackedScene

var speed := 20.0

var peep_manager : PeepManager

#@export var peep_texture : Texture2D

enum group_states {STOPPED, WALKING, OBSERVING, RESTING, USING_TOILET, INSIDE_RESTAURANT, GOING_TO_ENTRANCE, GOING_TO_FOOD, GOING_TO_RESTAURANT, GOING_TO_BENCH, GOING_TO_EXIT, GOING_TO_TOILET, GOING_TO_ENCLOSURE, WAITING_ANIMAL}

## move_states are processed into actual movement
var move_states : Array[group_states] = [group_states.WALKING, group_states.GOING_TO_ENCLOSURE, group_states.GOING_TO_FOOD, group_states.GOING_TO_RESTAURANT, group_states.GOING_TO_BENCH, group_states.GOING_TO_EXIT, group_states.GOING_TO_TOILET, group_states.GOING_TO_ENTRANCE]

## busy_states can't be overriden by another state
var busy_states : Array[group_states] = [group_states.GOING_TO_FOOD, group_states.GOING_TO_RESTAURANT, group_states.GOING_TO_BENCH, group_states.GOING_TO_TOILET]

var group_state : group_states = group_states.STOPPED

var peeps : Array[Peep] = []

var id : int

var agent : NavigationAgent2D

var direction : Vector2

## Holds all data for desired destinations
var group_desired_destinations = []
var group_desired_animals : Array[IdRefs.ANIMAL_SPECIES] = []

## Holds just the ids for desired enclosures
var desired_enclosure_ids = []

var first_position_offset := Vector2(0, -5)
var second_position_offset := Vector2(-5, 0)
var third_position_offset := Vector2(5, 0)

var position_offsets = [Vector2(0, -6), Vector2(-6, 0), Vector2(6, 0), Vector2(0, 6), Vector2(0, 0)]

var observed_animals : Array[IdRefs.ANIMAL_SPECIES]
var favorite_animal : IdRefs.ANIMAL_SPECIES
var observed_animals_happiness_sum : float = 0

var searching_rest_spot : bool = false
#var moving_towards_fixture : bool = false
var searching_food_spot : bool = false
#var moving_towards_food : bool = false
var searching_toilet : bool = false

var moving_towards_exit : bool = false
var moving_towards_entrance : bool = true

var bench : FixtureBench = null

#var chosen_shop : Shop = null
var target_building : Building = null
var visited_buildings : Array[Building] = []
var peep_group_inventory : Array[product_resource]
var holding_item = false
var has_entered_zoo : bool = false

var prefers_restaurants : bool = false

var target_toilet : Building = null

var modifiers = []

## Defines how tolerant peep group is to product's prices, higher is more exigent
var min_utility_score_tolerance : float
var min_product_level : int

var zoo_rating_score : float = 3

var cached_position : Vector2

var spent_money : float = 0

var z_index_value

var load_data

signal peep_group_left
signal peep_count_added



var needs_rest : float = randf_range(75, 100):
	set(value):
		needs_rest = clamp(value,0,100)
		if value < 35:
			searching_rest_spot = true
		if value < 1:
			if !modifiers.has(ThoughtManager.PEEP_THOUGHTS.NO_REST_SPOT):
				modifiers.append(ThoughtManager.PEEP_THOUGHTS.NO_REST_SPOT)

var needs_hunger : float = randf_range(50, 80):
	set(value):
		needs_hunger = clamp(value,0,100)
		if value <= 40:
			searching_food_spot = true
		if value < 1:
			if !modifiers.has(ThoughtManager.PEEP_THOUGHTS.NO_FOOD):
				modifiers.append(ThoughtManager.PEEP_THOUGHTS.NO_FOOD)
			
var needs_toilet : float = randf_range(50, 80):
	set(value):
		needs_toilet = clamp(value,0,100.0)
		if value < 35:
			searching_toilet = true
		if value < 1:
			if !modifiers.has(ThoughtManager.PEEP_THOUGHTS.NO_TOILET):
				modifiers.append(ThoughtManager.PEEP_THOUGHTS.NO_TOILET)
		
		
var hunger_drain_rate : float = randf_range(0.5, 2)
var rest_drain_rate : float = randf_range(1, 2)
var toilet_drain_rate : float = randf_range(0.5, 1.5)

var peep_count = null

@onready var screenNotifier = $VisibleOnScreenNotifier2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	agent = $NavigationAgent2D as NavigationAgent2D
	await get_tree().create_timer(0.5).timeout
	agent.path_desired_distance = randi_range(5, 15)
	
	min_utility_score_tolerance = randf_range(0.6, 1.5)
	

	agent.waypoint_reached.connect(on_agent_waypoint_reached)
	#agent.navigation_finished.connect(on_agent_target_reached)
	
	#$AnimalDetector.body_entered.connect(on_animal_detector_body_entered)
	#$FixtureDetector.area_entered.connect(on_fixture_detector_area_entered)
	#$GuestBuilding.area_entered.connect(on_guest_building_detector_area_entered)
	
	$Detector.area_entered.connect(on_detector_area_entered)
	#$Detector.body_entered.connect(on_detector_body_entered)
	
	$StateTimer.timeout.connect(on_state_timer_timeout)
	$DecayTimer.timeout.connect(on_decay_timer_timeout)
	
	$AnimalWaitTimer.timeout.connect(on_animal_wait_timer_timeout)
	
	$StuckTimer.timeout.connect(check_if_group_stuck)
	
	SignalBus.path_erased.connect(on_path_erased)

	
	$VisibleOnScreenNotifier2D.screen_entered.connect(on_visibility_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(on_visibility_exited)
	
	initialize_peep_group(load_data)
	change_state(group_states.STOPPED)

func initialize_peep_group(data):
	if data:
		id = data.id
		global_position = data.spawn_location
		$Peeps.global_position = data.spawn_location
		needs_rest = data.needs_rest
		needs_hunger = data.needs_hunger
		needs_toilet  = data.needs_toilet
		peep_count = data.peep_count
		min_product_level = data.min_product_level
		moving_towards_entrance = false
		for animal in data.observed_animals:
			observed_animals.append(int(animal))
		#for id in data.desired_destinations_id:
			#desired_enclosures_id.append(int(id))
		#for id in desired_enclosures_id:
			#if ZooManager.zoo_enclosures.keys().has(id):
				#group_desired_animals.append(ZooManager.zoo_enclosures[id]['especies'].species_id)
	else:
		peep_count = randi_range(1,4)
		favorite_animal = ContentManager.animals.keys().pick_random()
		speed = randi_range(16, 24)
		var randi = randi_range(0,10)
		if randi <= 6:
			min_product_level = 1
		elif randi <= 9:
			min_product_level = 2
		else:
			min_product_level = 3
			
	initialize_peep_group_destinations()
	
	## TODO - add to save
	if randi_range(0, 10) >= 7:
		prefers_restaurants = true
			
	if !peep_count:
		## TODO - Figure out what causes this bug in saves
		queue_free()
		return
		
	for i in range(peep_count):
		var peep = peep_scene.instantiate()
		peeps.append(peep)
		#peep_manager.peeps.append(peep)
		peep.position_offset = position_offsets[i]
		peep.position = position_offsets[i]
		peep.z_index = Helpers.get_current_tile_z_index(global_position)
		$Peeps.add_child(peep)
	peep_count_added.emit(peep_count)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
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
	SoundscapeManager.peeps_in_screen += 1
func on_visibility_exited():
	SoundscapeManager.peeps_in_screen -= 1

func on_agent_waypoint_reached(d):
	await get_tree().create_timer(0.05).timeout
	direction = (agent.get_next_path_position() - global_position).normalized()
	
func on_agent_target_reached():
	if group_state == group_states.GOING_TO_ENCLOSURE:
		change_state(group_states.WAITING_ANIMAL)
	elif group_state == group_states.GOING_TO_BENCH:
		change_state(group_states.RESTING)
	elif group_state == group_states.GOING_TO_FOOD:
		buy_food()
	elif group_state == group_states.GOING_TO_EXIT:
		leave_zoo()
	elif group_state == group_states.GOING_TO_TOILET:
		use_toilet()
	elif group_state == group_states.GOING_TO_ENTRANCE:
		var entrance_utility_score = Helpers.get_utility_score(ZooManager.entrance_perceived_value, ZooManager.entrance_price, 2, 0)
		if entrance_utility_score > min_utility_score_tolerance:
			if entrance_utility_score > 1.75:
				modifiers.append(ThoughtManager.PEEP_THOUGHTS.GREAT_VALUE_ENTRANCE)
			spent_money += (ZooManager.entrance_price * peep_count)
			FinanceManager.add(ZooManager.entrance_price * peep_count, IdRefs.PAYMENT_ADD_TYPES.ENTRANCE)
			SignalBus.money_tooltip.emit(ZooManager.entrance_price * peep_count, true, global_position)
			moving_towards_entrance = false
			has_entered_zoo = true
			get_new_destination()
		else:
			moving_towards_entrance = false
			moving_towards_exit = true
			change_state(group_states.STOPPED)
	else:
		change_state(group_states.STOPPED)

func change_state(state):
	group_state = state
	if state == group_states.GOING_TO_ENCLOSURE:
		agent.target_position = group_desired_destinations.front()['view_position']
		direction = (agent.get_next_path_position() - global_position).normalized()
		for peep in peeps:
			peep.change_state(1)
	elif state == group_states.OBSERVING:
		$Detector/CollisionShape2D.shape.radius = 150
		$StateTimer.wait_time = 20
		$StateTimer.start()
		for peep in peeps:
			peep.change_state(state)
	elif state == group_states.WAITING_ANIMAL:
		$AnimalWaitTimer.start()
		$Detector/CollisionShape2D.shape.radius = 250
		for peep in peeps:
			peep.change_state(0)
	elif state == group_states.WALKING:
		agent.target_position = group_desired_destinations.front()['view_position']
		direction = (agent.get_next_path_position() - global_position).normalized()
		for peep in peeps:
			peep.change_state(state)
	elif state == group_states.STOPPED:
		$StateTimer.wait_time = 5
		$StateTimer.start()
		for peep in peeps:
			peep.change_state(state)
	elif state == group_states.RESTING:
		if !bench:
			change_state(group_states.STOPPED)
			searching_rest_spot = true
			return
		needs_rest = 100
		$StateTimer.wait_time = 20
		$StateTimer.start()
		z_index_value = bench.z_index
		for i in range(peep_count):
			if i == 0:
				peeps[0].change_state(3)
				peeps[0].global_position = bench.sitting_posisitions[0]
				peeps[0].set_look_direction(bench.direction)
			elif i == 1:
				peeps[1].change_state(3)
				peeps[1].global_position = bench.sitting_posisitions[1]
				peeps[1].set_look_direction(bench.direction)
			else:
				peeps[i].change_state(0)
	elif state == group_states.GOING_TO_FOOD:
		if !target_building:
			change_state(group_states.STOPPED)
			return
		if target_building.building_res.is_building_entereable:
			agent.target_position = target_building.enter_positions.pick_random()
		else:
			agent.target_position = target_building.sell_positions.pick_random()
		for peep in peeps:
			peep.change_state(1)
		return
	elif state == group_states.GOING_TO_BENCH:
		for peep in peeps:
			peep.change_state(1)
		return
	elif state == group_states.GOING_TO_TOILET:
		if !target_toilet:
			change_state(group_states.STOPPED)
			return
		agent.target_position = target_toilet.enter_positions.pick_random()
		for peep in peeps:
			peep.change_state(1)
		return
	elif state == group_states.GOING_TO_EXIT:
		agent.target_position = Vector2(-1510,790)
		moving_towards_exit = true
		for peep in peeps:
			peep.change_state(1)
	elif state == group_states.GOING_TO_ENTRANCE:
		agent.target_position = ZooManager.get_entrance_point()
		for peep in peeps:
			peep.change_state(1)
	elif state == group_states.INSIDE_RESTAURANT:
		$RestaurantTimer.start()
		

func get_new_destination():
	if searching_food_spot:
		target_building = search_food_place()
		if !target_building:
			change_state(group_states.GOING_TO_EXIT)
			return
		else:
			change_state(group_states.GOING_TO_FOOD)
			return
	if searching_toilet:
		target_toilet = search_toilet()
		if !target_toilet:
			change_state(group_states.GOING_TO_EXIT)
			return
		else:
			change_state(group_states.GOING_TO_TOILET)
			return
	elif moving_towards_exit:
		change_state(group_states.GOING_TO_EXIT)
		return
	elif group_desired_destinations.is_empty():
		change_state(group_states.GOING_TO_EXIT)
		return
	elif moving_towards_entrance:
		change_state(group_states.GOING_TO_ENTRANCE)
		return
	else:
		change_state(group_states.GOING_TO_ENCLOSURE)


func move_toward_direction(direction: Vector2, delta: float):
	global_position += direction * speed * delta
	

func on_detector_area_entered(area):
	if group_state in busy_states:
		return
		
	if area.get_parent() is Animal:
		var animal = area.get_parent() as Animal
		if animal.is_dead:
			if ThoughtManager.PEEP_THOUGHTS.SAW_DEAD_ANIMAL not in modifiers:
				modifiers.append(ThoughtManager.PEEP_THOUGHTS.SAW_DEAD_ANIMAL)
		if animal.animal_species not in observed_animals:
			observed_animals.append(animal.animal_species)
			change_state(group_states.OBSERVING)
			observed_animals_happiness_sum += animal.habitat_happiness
			if animal.habitat_happiness <= 2:
				modifiers.append(ThoughtManager.PEEP_THOUGHTS.SAW_UNHAPPY_ANIMAL)
			$AnimalWaitTimer.stop()
			for peep in peeps:
				var dir = global_position.direction_to(animal.global_position).angle()
				peep.look_direction = dir
				
			if animal.animal_species in group_desired_animals:
				group_desired_animals.erase(animal.animal_species)
		
		for destination in group_desired_destinations:
			if destination['species'] == animal.animal_res.species_id:
				group_desired_destinations.erase(destination)
				desired_enclosure_ids.erase(destination['enclosure_id'])
		
	elif searching_rest_spot:
		if area.get_parent().get_parent() is FixtureBench:
			bench = area.get_parent().get_parent()
			if !bench:
				change_state(group_states.STOPPED)
				return
			if !bench.is_available:
				return
			else:
				agent.target_position = bench.global_position
				bench.is_available = false
				direction = (agent.get_next_path_position() - global_position).normalized()
				change_state(group_states.GOING_TO_BENCH)
				searching_rest_spot = false

func on_state_timer_timeout():
	if group_state == group_states.OBSERVING:
		get_new_destination()
	if group_state == group_states.STOPPED:
		get_new_destination()
	if group_state == group_states.RESTING:
		if is_instance_valid(bench):
			bench.is_available = true
			get_new_destination()
		else:
			get_new_destination()

func on_decay_timer_timeout():
	needs_rest -= rest_drain_rate
	needs_hunger -= hunger_drain_rate
	needs_toilet -= toilet_drain_rate

func on_animal_wait_timer_timeout():
	$Detector/CollisionShape2D.shape.radius = 150
	if group_desired_destinations.size() > 0:
		group_desired_destinations.erase(group_desired_destinations.front())
	change_state(group_states.STOPPED)

func buy_food():
	change_state(group_states.STOPPED)
	var available_items = {}
	
	## In case shop has ceased to exist
	if !target_building or !target_building.is_shop:
		change_state(group_states.STOPPED)
		return
		
		
	if target_building.available_products.size() == 0:
		target_building.add_peep_modifier(ThoughtManager.PEEP_THOUGHTS.EMPTY_SHOP)
		modifiers.append(ThoughtManager.PEEP_THOUGHTS.EMPTY_SHOP)
		visited_buildings.append(target_building)
		return
		
	## Select items of desirable quality
	for id in target_building.available_products:
		if target_building.available_products[id].product.type == IdRefs.PRODUCT_TYPES.FOOD:
			if target_building.available_products[id].product.product_level >= min_product_level:
				var level_delta = min_product_level - target_building.available_products[id].product.product_level
				var item_utility_score = Helpers.get_utility_score(target_building.available_products[id].product.perceived_value,
				 target_building.available_products[id].current_price,
				target_building.available_products[id].product.product_level,
				level_delta
				)
					
				available_items[target_building.available_products[id].product.id] = {
					'utility_score': item_utility_score
					}
					

	var best_item_id = null
	var highest_utility = 0
			
	## No items of desirable quality
	if available_items.size() == 0:
		target_building.add_peep_modifier(ThoughtManager.PEEP_THOUGHTS.NO_DESIRABLE_QUALITY)
		modifiers.append(ThoughtManager.PEEP_THOUGHTS.NO_DESIRABLE_QUALITY)
		
	## Choose preferred item based on best perceived value
	else:
		for id in available_items:
			if available_items[id].utility_score > highest_utility:
				if available_items[id].utility_score < min_utility_score_tolerance:
					continue
				highest_utility = available_items[id].utility_score
				best_item_id = id

		## Found no items of desirable cost
		if best_item_id == null:
			target_building.add_peep_modifier(ThoughtManager.PEEP_THOUGHTS.TOO_EXPENSIVE)
			modifiers.append(ThoughtManager.PEEP_THOUGHTS.TOO_EXPENSIVE)


	## Found item of desirable cost and quality
	if target_building and best_item_id != null:
		## Enter restaurant and eat meal
		if target_building.building_res.is_building_entereable:
			if target_building.buy(best_item_id, peep_count):
				change_state(group_states.INSIDE_RESTAURANT)
				searching_food_spot = false
				visible = false
				## Doing this to see if bug where target_building ceases existing is fixed
				var amount = target_building.available_products[best_item_id].current_price * peep_count
				await $RestaurantTimer.timeout
				needs_hunger = 100.0
				needs_toilet = 100.0
				needs_rest = 100.0
				visible = true
				change_state(group_states.STOPPED)
				spent_money += amount
				modifiers.append(ThoughtManager.PEEP_THOUGHTS.ATE_AT_RESTAURANT)
				if available_items[best_item_id].utility_score > 1.5:
					target_building.add_peep_modifier(ThoughtManager.PEEP_THOUGHTS.GREAT_VALUE_FOOD)
					modifiers.append(ThoughtManager.PEEP_THOUGHTS.GREAT_VALUE_FOOD)
				for peep in peeps:
					SignalBus.money_tooltip.emit(amount, true, peep.global_position)
			else:
				target_building.add_peep_modifier(ThoughtManager.PEEP_THOUGHTS.NO_SHOP_STOCK)
				modifiers.append(ThoughtManager.PEEP_THOUGHTS.NO_SHOP_STOCK)
			
		## Buy product and eat outside
		else:
			if target_building.buy(best_item_id, peep_count):
				peep_group_inventory.append(target_building.available_products[best_item_id].product)
				needs_hunger = 100
				searching_food_spot = false
				searching_rest_spot = true
				holding_item = true
				for peep in peeps:
					peep.holding_item = true
				spent_money += target_building.available_products[best_item_id].current_price * peep_count
				if available_items[best_item_id].utility_score > 1.5:
					target_building.add_peep_modifier(ThoughtManager.PEEP_THOUGHTS.GREAT_VALUE_FOOD)
					modifiers.append(ThoughtManager.PEEP_THOUGHTS.GREAT_VALUE_FOOD)
				for peep in peeps:
					SignalBus.money_tooltip.emit(target_building.available_products[best_item_id].current_price, true, peep.global_position)
			else:
				target_building.add_peep_modifier(ThoughtManager.PEEP_THOUGHTS.NO_SHOP_STOCK)
				modifiers.append(ThoughtManager.PEEP_THOUGHTS.NO_SHOP_STOCK)
	
	visited_buildings.append(target_building)
	target_building = null
	change_state(group_states.STOPPED)

func use_toilet():
	group_state = group_states.USING_TOILET
	for peep in peeps:
		peep.visible = false
	needs_toilet = 100.0
	searching_toilet = false
	await get_tree().create_timer(10).timeout
	for peep in peeps:
		peep.visible = true
	get_new_destination()

func initialize_peep_group_destinations():
	
	if load_data:
		desired_enclosure_ids = load_data.desired_enclosure_ids
	
	else:
		var enclosure_keys = ZooManager.zoo_enclosures.keys()
		if enclosure_keys.size() == 0:
			return
			## Generate random desired enclosures
		for i in range(5):
			if enclosure_keys.size() == 0:
				break
			var random_id = enclosure_keys.pick_random()
			enclosure_keys.erase(random_id)
			if ZooManager.zoo_enclosures[random_id]['species'] == null:
				continue
			desired_enclosure_ids.append(random_id)
				

	## Initialize destinations
	for id in desired_enclosure_ids:
		if !ZooManager.zoo_enclosures[int(id)]['species']:
			continue
		var destination = {"enclosure_id": int(id), "species": ZooManager.zoo_enclosures[int(id)]['species'].species_id, "view_position": ZooManager.zoo_enclosures[int(id)].node.enclosure_view_positions.pick_random()}
		group_desired_destinations.append(destination)
		group_desired_animals.append(destination['species'])

	## TODO - Sort group_desired_destinations
	
func leave_zoo():
	var rating
	if has_entered_zoo:
		if group_desired_destinations.size() == 0 and observed_animals.size() > 3:
			modifiers.append(ThoughtManager.PEEP_THOUGHTS.SEEN_ALL_DESIRED_ANIMALS)
		if observed_animals.size() < 3:
			modifiers.append(ThoughtManager.PEEP_THOUGHTS.SEEN_FEW_ANIMALS)
		if group_desired_animals.size() > 0:
			modifiers.append(ThoughtManager.PEEP_THOUGHTS.MISSED_ANIMAL)
		if favorite_animal in observed_animals:
			modifiers.append(ThoughtManager.PEEP_THOUGHTS.SEEN_FAVORITE_ANIMAL)
		if !modifiers.has(ThoughtManager.PEEP_THOUGHTS.NO_TOILET) and !modifiers.has(ThoughtManager.PEEP_THOUGHTS.NO_FOOD) and !modifiers.has(ThoughtManager.PEEP_THOUGHTS.NO_REST_SPOT):
			modifiers.append(ThoughtManager.PEEP_THOUGHTS.FILLED_NEEDS)
		if observed_animals_happiness_sum / observed_animals.size() > 4.8:
			modifiers.append(ThoughtManager.PEEP_THOUGHTS.ONLY_SAW_HAPPY_ANIMALS)
		rating = calculate_perceived_zoo_rating()
	else:
		rating = -1
	peep_group_left.emit(self, rating)

func update_cached_position():
	cached_position = global_position

func calculate_perceived_zoo_rating():
	var sum = 0
	for modifier in modifiers:
		sum += ThoughtManager.peep_thoughts[modifier].point_value
	return clamp(zoo_rating_score + sum, 0, 5)

func search_food_place():
	var shorter_distance = 100000
	var selected_food_place = null
	var too_far_count = 0
	## If group prefers restaurants, look up a restaurant to go to
	if prefers_restaurants:
		for restaurant_id in ZooManager.restaurants:
			if ZooManager.restaurants[restaurant_id].scene in visited_buildings:
				continue
			var distance = global_position.distance_to(ZooManager.restaurants[restaurant_id].position)
			if distance < shorter_distance:
				selected_food_place = ZooManager.restaurants[restaurant_id].scene
			else:
				too_far_count += 1
				
	## If a group does not prefers restaurants, look for eatery
	## If a group prefers restaurants but hasn't found one, look for eatery
	if !selected_food_place:
		for eatery_id in ZooManager.eateries:
			if ZooManager.eateries[eatery_id].scene in visited_buildings:
				continue
			var distance = global_position.distance_to(ZooManager.eateries[eatery_id].position)
			if distance < shorter_distance:
				selected_food_place = ZooManager.eateries[eatery_id].scene
			else:
				too_far_count += 1

	if selected_food_place:
		return selected_food_place
	else:
		if too_far_count > 0:
			modifiers.append(ThoughtManager.PEEP_THOUGHTS.NO_FOOD_SHOP_IN_RANGE)
		return null
		
func search_toilet():
	var selected_toilet
	var shorter_distance = 100000
	for toilet in ZooManager.toilets:
		var distance = global_position.distance_to(ZooManager.toilets[toilet].position)
		if distance < shorter_distance:
			selected_toilet = ZooManager.toilets[toilet].scene
			
	if selected_toilet:
		return selected_toilet
	else:
		modifiers.append(ThoughtManager.PEEP_THOUGHTS.NO_TOILET)
		return null

func on_path_erased(cell):
	if cell == TileMapRef.local_to_map(global_position):
		reset_state()
		
## I can trigger this function arbitrarily on both working agents and out of bounds agents
func check_if_group_stuck():
	## I'm correctly getting the RID from my NavigationRegion2D node
	var tilemap_rid = TileMapRef.get_navigation_rid()
	if tilemap_rid:
		## This always returns Vector2(0,0)
		var distance_to_tilemap = NavigationServer2D.map_get_closest_point(tilemap_rid, global_position)
		if distance_to_tilemap is Vector2 and distance_to_tilemap > Vector2.ZERO:
			reset_state()
		
func reset_state():
	change_state(group_states.STOPPED)
	global_position = Vector2(-1300, 675)
