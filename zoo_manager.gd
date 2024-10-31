extends Node

## Represents total level of quality of zoo from available attractions and boosts
var zoo_rating : int:
	set(value):
		zoo_rating = value
		calculate_zoo_attractiveness()
		
## How much the rating value impacts attractiveness
var rating_ratio = 0.4

## Represents current maximum number of guests in zoo
var zoo_attractiveness : int

var zoo_animals : Dictionary = {}
var animal_rating : int
		
var zoo_enclosures : Dictionary = {}
var next_enclosure_id = 1

var active_boosts : Dictionary = {}
var boost_rating : int = 0

## Represents level of satisfaction from guests
var reputation : float = 5:
	set(value):
		reputation = clamp(value, 0, 5)
		calculate_zoo_attractiveness()
		
var last_guest_ratings = [3, 3, 3, 3, 3, 3, 3, 3, 3, 3]

#var zoo_value : int
#var animal_rating : int
var current_boost_value : int
var current_marketing_value : int


func _ready() -> void:
	
	pass # Replace with function body.


func add_zoo_enclosure(enclosure : Enclosure):
	zoo_enclosures[enclosure.id] = {"location": enclosure.enclosure_central_point, "especies": enclosure.enclosure_species}
	
func update_zoo_enclosure(enclosure):
	zoo_enclosures[enclosure.id] = {"location": enclosure.enclosure_central_point, "especies": enclosure.enclosure_species}
	if enclosure.enclosure_species:
		if enclosure.enclosure_species.name not in zoo_animals:
			zoo_animals[enclosure.enclosure_species.name] = {"rating": enclosure.enclosure_species.animal_rating}
	calculate_animal_rating()
	
func remove_zoo_enclosure(enclosure):
	zoo_enclosures.erase(enclosure.id)

func generate_enclosure_id() -> int:
	next_enclosure_id += 1
	return next_enclosure_id

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
	zoo_attractiveness = float(zoo_rating * rating_ratio) * (reputation * 0.20)

func update_rating(new_rating):
	last_guest_ratings.append(new_rating)
	last_guest_ratings.remove_at(0)
	var median = 0
	for value in last_guest_ratings:
		median += value
		
	median = median / last_guest_ratings.size()
	reputation = median
