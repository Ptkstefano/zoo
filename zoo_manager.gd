extends Node

var zoo_rating : int:
	set(value):
		zoo_rating = value
		
var zoo_enclosures = {}
var used_enclosure_ids : Array[int]
		
var zoo_value : int
var zoo_animal_rating : int
var current_boost_value : int
var current_marketing_value : int


func _ready() -> void:
	pass # Replace with function body.


func add_zoo_enclosure(enclosure : Enclosure):
	zoo_enclosures[enclosure.id] = {"location": enclosure.enclosure_central_point, "species_rating": enclosure.enclosure_species.animal_rating, "especies": enclosure.enclosure_species}

func remove_zoo_enclosure(enclosure):
	pass

func generate_enclosure_id() -> int:
	var i = 1
	while used_enclosure_ids.has(i):
		i += 1
	used_enclosure_ids.append(i)
	return i
