extends Node

var zoo_rating : int:
	set(value):
		zoo_rating = value
		
var zoo_enclosures = {}
var next_enclosure_id = 1

		
var zoo_value : int
var zoo_animal_rating : int
var current_boost_value : int
var current_marketing_value : int


func _ready() -> void:
	pass # Replace with function body.


func add_zoo_enclosure(enclosure : Enclosure):
	zoo_enclosures[enclosure.id] = {"location": enclosure.enclosure_central_point, "especies": enclosure.enclosure_species}
	
func update_zoo_enclosure(enclosure):
	zoo_enclosures[enclosure.id] = {"location": enclosure.enclosure_central_point, "especies": enclosure.enclosure_species}
	
func remove_zoo_enclosure(enclosure):
	zoo_enclosures.erase(enclosure.id)

func generate_enclosure_id() -> int:
	next_enclosure_id += 1
	return next_enclosure_id
