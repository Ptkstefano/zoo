extends Node
	
## Content Manager handles all available content in the game and loads it at runtime
	
@export var animal_resources : Array[animal_resource]
@export var restaurant_resources : Array[building_resource]
@export var eatery_resources : Array[building_resource]
@export var service_resources : Array[building_resource]
@export var administration_resources : Array[building_resource]
@export var product_resources : Array[product_resource]
@export var vegetation_resources : Array[vegetation_resource]
@export var tree_resources : Array[tree_resource]
@export var decoration_resources : Array[decoration_resource]
@export var fixture_resources : Array[fixture_resource]
@export var terrain_resources : Array[terrain_resource]
@export var path_resources : Array[path_resource]
@export var fence_resources : Array[fence_resource]
@export var shelter_resources : Array[shelter_resource]
@export var lake_resources : Array[lake_resource]

var animals = {}
var restaurants = {}
var eateries = {}
var services = {}
var administration = {}
var products = {}
var vegetation = {}
var trees = {}
var decoration = {}
var fixtures = {}
var terrains = {}
var paths = {}
var fences = {}
var shelters = {}
var lakes = {}
	
func _ready():
	load_all_resources()


func load_all_resources() -> void:
	for resource in animal_resources:
		animals[resource.id] = resource
		
	for resource in restaurant_resources:
		restaurants[resource.id] = resource
		
	for resource in eatery_resources:
		eateries[resource.id] = resource
		
	for resource in service_resources:
		services[resource.id] = resource
		
	for resource in administration_resources:
		administration[resource.id] = resource
		
	for resource in product_resources:
		products[resource.id] = resource
		
	for resource in vegetation_resources:
		vegetation[resource.id] = resource
		
	for resource in tree_resources:
		trees[resource.id] = resource
		
	for resource in decoration_resources:
		decoration[resource.id] = resource
		
	for resource in fixture_resources:
		fixtures[resource.id] = resource
		
	for resource in terrain_resources:
		terrains[resource.id] = resource
		
	for resource in path_resources:
		paths[resource.id] = resource
		
	for resource in fence_resources:
		fences[resource.id] = resource

	for resource in shelter_resources:
		shelters[resource.id] = resource 
		
	for resource in lake_resources:
		lakes[resource.id] = resource
		
