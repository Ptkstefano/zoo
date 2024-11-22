extends Node
	
## Content Manager handles all available content in the game and loads it at runtime
	
@export var animal_files : Array[animal_resource]

@export var product_resources : Array[product_resource]

var animals = {}
var products = {}
	
func _ready():
	load_all_resources()


func load_all_resources() -> void:
	for file in animal_files:
		animals[file.species_id] = file
		
	for product in product_resources:
		products[product.id] = product
	
