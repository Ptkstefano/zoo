extends Node

## Represents total level of quality of zoo from available attractions and boosts
var zoo_rating : int:
	set(value):
		zoo_rating = value
		calculate_zoo_attractiveness()
		calculate_entrance_perceived_value()
		
		
var entrance_price : float = 10
var zoo_entrance_open : bool = false
var entrance_perceived_value : float = 10.0
		
## How much the rating value impacts attractiveness
## This value defines the difficulty of the game: higher values spawn more peeps
var rating_ratio = 0.75

## Represents current maximum number of guests in zoo
var zoo_attractiveness : int:
	set(value):
		zoo_attractiveness = value
		calculate_entrance_perceived_value()

var zoo_animals : Dictionary = {}

var animal_rating : int
		
var next_animal_id = 0

var next_scenery_id = 0

var next_building_id = 0

var used_peep_group_ids = []
		
var zoo_enclosures : Dictionary = {}
var next_enclosure_id = 0

var enclosures_needing_work = []

var eateries = {}
var restaurants = {}
var toilets = {}

var active_boosts : Dictionary = {}
var boost_rating : int = 0

var peep_count : int:
	set(value):
		peep_count = value
		peep_count_updated.emit(value)

## Represents level of satisfaction from guests
var reputation : float = 5:
	set(value):
		reputation = clamp(value, 0, 5)
		calculate_zoo_attractiveness()
		calculate_entrance_perceived_value()
		
signal zoo_reputation_updated
signal peep_count_updated
		
var last_guest_ratings = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3]

## Stores 10 most recent full reviews
var review_list = []

## Stores last 100 group thoughts
var modifier_list = []

signal reviews_changed

#var zoo_value : int
#var animal_rating : int
var current_boost_value : int
var current_marketing_value : int


func _ready() -> void:
	zoo_reputation_updated.emit(reputation)

func add_zoo_enclosure(enclosure : Enclosure):
	zoo_enclosures[enclosure.id] = {"node": enclosure, "location": enclosure.enclosure_central_point, "species": enclosure.enclosure_species, "entrance_cell": null}
	
func update_zoo_enclosure(enclosure):
	zoo_enclosures[enclosure.id] = {"node": enclosure, "location": enclosure.enclosure_central_point, "species": enclosure.enclosure_species, "entrance_cell": enclosure.entrance_cell}
	if enclosure.enclosure_species:
		if enclosure.enclosure_species.name not in zoo_animals:
			zoo_animals[enclosure.enclosure_species.name] = {"rating": enclosure.enclosure_species.animal_rating, "enclosures": [enclosure.id]}
		else:
			if enclosure.id not in zoo_animals[enclosure.enclosure_species.name]["enclosures"]:
				zoo_animals[enclosure.enclosure_species.name]["enclosures"].append(enclosure.id)
	else:
		for animal in zoo_animals:
			if zoo_animals[animal]["enclosures"].has(enclosure.id):
				zoo_animals[animal]["enclosures"].erase(enclosure.id)
				if zoo_animals[animal]["enclosures"].is_empty():
					zoo_animals.erase(animal)
	
	calculate_animal_rating()
	
func add_eatery(id, data):
	ZooManager.eateries[id] = { 'building': data.building, 'position': TileMapRef.map_to_local(data.position) }
	
func remove_eatery(id):
	ZooManager.eateries.erase(id)
	
func add_restaurant(id, data):
	ZooManager.restaurants[id] = { 'building': data.building, 'position': TileMapRef.map_to_local(data.position) }
	
func remove_restaurant(id):
	ZooManager.restaurants.erase(id)
	
func add_toilet(id, data):
	ZooManager.toilets[id] = { 'building': data.building, 'position': TileMapRef.map_to_local(data.position) }
	
func remove_toilet(id):
	ZooManager.toilets.erase(id)
	
func remove_zoo_enclosure(enclosure):
	enclosures_needing_work.erase(enclosure)
	zoo_enclosures.erase(enclosure.id)
	## Remove animal?

func generate_enclosure_id() -> int:
	next_enclosure_id += 1
	return next_enclosure_id

func generate_animal_id() -> int:
	next_animal_id += 1
	return next_animal_id

func generate_scenery_id() -> int :
	next_scenery_id += 1
	return next_scenery_id

func generate_building_id() -> int:
	next_building_id += 1
	return next_building_id
	
func generate_peep_group_id():
	var i = 0
	while i in used_peep_group_ids:
		i += 1
	used_peep_group_ids.append(i)
	return i
		
func remove_peep_group_id(id):
	used_peep_group_ids.erase(id)
		
func calculate_animal_rating():
	animal_rating = 0
	for animal in zoo_animals:
		animal_rating += zoo_animals[animal].rating
	calculate_zoo_rating()

func calculate_zoo_rating():
	zoo_rating = 0
	zoo_rating += animal_rating
	zoo_rating += boost_rating
	calculate_zoo_attractiveness()

func calculate_zoo_attractiveness():
	zoo_attractiveness = float(zoo_rating * rating_ratio) * (clampf(reputation, 0.25, 5) * 0.3)
	zoo_reputation_updated.emit(reputation)

func update_rating(new_rating):
	last_guest_ratings.append(new_rating)
	last_guest_ratings.remove_at(0)
	var median = 0
	for value in last_guest_ratings:
		median += value
		
	median = median / last_guest_ratings.size()
	reputation = median

func get_entrance_point():
	var entrance = get_tree().get_nodes_in_group('EntranceSpot').pick_random().global_position
	return entrance

func  store_peep_group_review(review):
	## review = {'rating': rating, 'thoughts': group.modifiers}
	if review_list.size() > 10:
		review_list.remove_at(0)
		
	review_list.append(review)
	reviews_changed.emit()
	
	
func store_recent_peep_group_modifiers(group_modifiers):
	for modifier in group_modifiers:
		if modifier_list.size() > 100:
			modifier_list.remove_at(0)
			
		modifier_list.append(modifier)
		
	reviews_changed.emit()

func set_zoo_entrance_open(value):
	zoo_entrance_open = value

func update_entrance_price(value):
	entrance_price = value

func calculate_entrance_perceived_value():
	## Value in money that is considered ideal pricing for the entrance
	entrance_perceived_value = (zoo_attractiveness + zoo_rating) * 0.03
