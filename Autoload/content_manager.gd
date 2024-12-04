extends Node
	
## Content Manager handles all available content in the game and loads it at runtime
	
@export var animal_files : Array[animal_resource]

@export var product_resources : Array[product_resource]

@export var building_resources : Array[building_resource]

var animals = {}
var products = {}
var buildings = {}
	
func _ready():
	load_all_resources()


func load_all_resources() -> void:
	for file in animal_files:
		animals[file.species_id] = file
		
	for product in product_resources:
		products[product.id] = product
	
	for element in building_resources:
		buildings[element.id] = element
		
