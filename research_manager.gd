extends Node

var unlocked_animals = {}
var unlocked_restaurants = {}
var unlocked_eateries = {}
var unlocked_services = {}
var unlocked_administration = {}
var unlocked_products = {}
var unlocked_vegetation = {}
var unlocked_trees = {}
var unlocked_decoration = {}
var unlocked_fixtures = {}

signal unlocked_animals_changed
signal unlocked_buildings_changed
signal unlocked_scenery_changed
signal unlocked_products_changed

var eligible_animals = []
var eligible_restaurants = []
var eligible_eateries = []
var eligible_administration = []
var eligible_services = []
var eligible_products = []
var eligible_vegetation = []
var eligible_trees = []
var eligible_decoration = []
var eligible_fixtures = []

var last_research

	
var current_research_progress : float = 0 :
	set(value):
		current_research_progress = clampf(value, 0.0, 100.0)
		research_progress_updated.emit()
	
var monthly_reseach_increase : float = 20
	
signal research_progress_updated
	
func _ready() -> void:
	TimeManager.on_pass_month.connect(on_pass_month)
	

func load_game(data):
	for animal_id in data['animals']:
		unlocked_animals[animal_id] = ContentManager.animals[animal_id]

func new_research_unlocked():
	if current_research_progress < 99:
		return
	
	current_research_progress = 0
	
	generate_eligible_research()
	
	var unlock_count = 3
	var eligible_categories = {
		"animals": eligible_animals,
		"restaurants": eligible_restaurants,
		"eateries": eligible_eateries,
		"administration": eligible_administration,
		"services": eligible_services,
		"trees": eligible_trees,
		"vegetation": eligible_vegetation,
		"decoration": eligible_decoration,
		"fixtures": eligible_fixtures,
		"products": eligible_products,
	}
	
	for key in eligible_categories.keys():
		if eligible_categories[key].is_empty():
			eligible_categories.erase(key)
	
	if eligible_categories.is_empty():
		return
	
	var new_unlocks = []
	while new_unlocks.size() < unlock_count:
		var category = eligible_categories.keys().pick_random()
		var random_element = eligible_categories[category].pick_random()
		var unlock = {'category': category, 'id': random_element}
		eligible_categories[category].erase(random_element)
		if eligible_categories[category].is_empty():
			eligible_categories[category].erase(random_element)
			if eligible_categories[category].is_empty():
				eligible_categories.erase(category)
				if eligible_categories.is_empty():
					break
		new_unlocks.append(unlock)
	
	last_research = new_unlocks
	
	for unlock in new_unlocks:
		if unlock.category == 'animals':
			unlocked_animals[unlock.id] = ContentManager.animals[unlock.id]
			unlocked_animals_changed.emit()
		elif unlock.category == 'restaurants':
			unlocked_restaurants[unlock.id] = ContentManager.restaurants[unlock.id]
			unlocked_buildings_changed.emit()
			if unlocked_restaurants[unlock.id].possible_products[0] not in unlocked_products.keys():
				unlocked_products[unlocked_restaurants[unlock.id].possible_products[0]] = ContentManager.products[unlocked_restaurants[unlock.id].possible_products[0]]
		elif unlock.category == 'eateries':
			unlocked_eateries[unlock.id] = ContentManager.eateries[unlock.id]
			unlocked_buildings_changed.emit()
			if unlocked_eateries[unlock.id].possible_products[0] not in unlocked_products.keys():
				unlocked_products[unlocked_eateries[unlock.id].possible_products[0]] = ContentManager.products[unlocked_eateries[unlock.id].possible_products[0]]
		elif unlock.category == 'administration':
			unlocked_administration[unlock.id] = ContentManager.administration[unlock.id]
			unlocked_buildings_changed.emit()
		elif unlock.category == 'services':
			unlocked_services[unlock.id] = ContentManager.services[unlock.id]
			unlocked_buildings_changed.emit()
		elif unlock.category == 'trees':
			unlocked_trees[unlock.id] = ContentManager.trees[unlock.id]
			unlocked_scenery_changed.emit()
		elif unlock.category == 'vegetation':
			unlocked_vegetation[unlock.id] = ContentManager.vegetation[unlock.id]
			unlocked_scenery_changed.emit()
		elif unlock.category == 'decoration':
			unlocked_decoration[unlock.id] = ContentManager.decoration[unlock.id]
			unlocked_scenery_changed.emit()
		elif unlock.category == 'fixtures':
			unlocked_fixtures[unlock.id] = ContentManager.fixtures[unlock.id]
			unlocked_scenery_changed.emit()
		elif unlock.category == 'products':
			unlocked_products[unlock.id] = ContentManager.products[unlock.id]
			unlocked_products_changed.emit()
	

func on_pass_month():
	print('update research')
	current_research_progress += monthly_reseach_increase

func generate_eligible_research():
	eligible_animals.clear()
	eligible_restaurants.clear()
	eligible_eateries.clear()
	eligible_administration.clear()
	eligible_services.clear()
	eligible_products.clear()
	eligible_vegetation.clear()
	eligible_trees.clear()
	eligible_decoration.clear()
	eligible_fixtures.clear()
	
	for id in ContentManager.animals.keys():
		if id not in unlocked_animals.keys():
			eligible_animals.append(id)
			
	for id in ContentManager.restaurants.keys():
		if id not in unlocked_restaurants.keys():
			eligible_restaurants.append(id)
			
	for id in ContentManager.eateries.keys():
		if id not in unlocked_eateries.keys():
			eligible_eateries.append(id)
			
	for id in ContentManager.services.keys():
		if id not in unlocked_services.keys():
			eligible_services.append(id)
			
	for id in ContentManager.administration.keys():
		if id not in unlocked_administration.keys():
			eligible_administration.append(id)
			
	for id in ContentManager.trees.keys():
		if id not in unlocked_trees.keys():
			eligible_trees.append(id)
			
	for id in ContentManager.vegetation.keys():
		if id not in unlocked_vegetation.keys():
			eligible_vegetation.append(id)
			
	for id in ContentManager.decoration.keys():
		if id not in unlocked_decoration.keys():
			eligible_decoration.append(id)
			
	for id in ContentManager.fixtures.keys():
		if id not in unlocked_fixtures.keys():
			eligible_fixtures.append(id)

	for restaurant in unlocked_restaurants.keys():
		for id in unlocked_restaurants[restaurant].possible_products:
			if id not in unlocked_products.keys():
				eligible_products.append(id)
				
	for eatery in unlocked_eateries.keys():
		for id in unlocked_eateries[eatery].possible_products:
			if id not in unlocked_products.keys():
				eligible_products.append(id)


func new_game_unlocks():
	var starting_animals = [IdRefs.ANIMAL_SPECIES.CAPYBARA, IdRefs.ANIMAL_SPECIES.AMERICAN_FLAMINGO, IdRefs.ANIMAL_SPECIES.WHITETAILED_DEER, IdRefs.ANIMAL_SPECIES.RED_FOX]
	var starting_administration = [IdRefs.BUILDINGS.ZOOKEEPER_STATION]
	var starting_services = [IdRefs.BUILDINGS.SMALL_BATHROOM]
	var starting_trees = [IdRefs.TREE_SPECIES.PALM, IdRefs.TREE_SPECIES.ARAUCARIA, IdRefs.TREE_SPECIES.LIMBER_PINE, IdRefs.TREE_SPECIES.ALDER]
	var starting_vegetation = [IdRefs.VEGETATION_SPECIES.SHORT_GRASS, IdRefs.VEGETATION_SPECIES.TALL_GRASS, IdRefs.VEGETATION_SPECIES.BERRY_BUSH]
	var starting_fixtures = [IdRefs.FIXTURES.WOODEN_BENCH, IdRefs.FIXTURES.STEEL_LAMP]
	
	for id in starting_animals:
		unlocked_animals[id] = ContentManager.animals[id]
		
	for id in starting_administration:
		unlocked_administration[id] = ContentManager.administration[id]
		
	for id in starting_services:
		unlocked_services[id] = ContentManager.services[id]
		
	for id in starting_trees:
		unlocked_trees[id] = ContentManager.trees[id]

	for id in starting_vegetation:
		unlocked_vegetation[id] = ContentManager.vegetation[id]
		
	for id in starting_fixtures:
		unlocked_fixtures[id] = ContentManager.fixtures[id]

	unlocked_animals_changed.emit()
	unlocked_buildings_changed.emit()
	unlocked_scenery_changed.emit()
	unlocked_products_changed.emit()

func load_data(data):
	for id in data['unlocked_animals']:
		unlocked_animals[int(id)] = ContentManager.animals[int(id)]
	for id in data['unlocked_restaurants']:
		unlocked_restaurants[int(id)] = ContentManager.restaurants[int(id)]
	for id in data['unlocked_eateries']:
		unlocked_eateries[int(id)] = ContentManager.eateries[int(id)]
	for id in data['unlocked_services']:
		unlocked_services[int(id)] = ContentManager.services[int(id)]
	for id in data['unlocked_administration']:
		unlocked_administration[int(id)] = ContentManager.administration[int(id)]
	for id in data['unlocked_products']:
		unlocked_products[int(id)] = ContentManager.products[int(id)]
	for id in data['unlocked_vegetation']:
		unlocked_vegetation[int(id)] = ContentManager.vegetation[int(id)]
	for id in data['unlocked_trees']:
		unlocked_trees[int(id)] = ContentManager.trees[int(id)]
	for id in data['unlocked_decoration']:
		unlocked_decoration[int(id)] = ContentManager.decoration[int(id)]
	for id in data['unlocked_fixtures']:
		unlocked_fixtures[int(id)] = ContentManager.fixtures[int(id)]

	unlocked_animals_changed.emit()
	unlocked_buildings_changed.emit()
	unlocked_scenery_changed.emit()
	unlocked_products_changed.emit()

func unlock_everything():
	generate_eligible_research()
	
	for id in eligible_animals:
		unlocked_animals[id] = ContentManager.animals[id]
	unlocked_animals_changed.emit()

	for id in eligible_restaurants:
		unlocked_restaurants[id] = ContentManager.restaurants[id]
	for id in eligible_eateries:
		unlocked_eateries[id] = ContentManager.eateries[id]
	for id in eligible_administration:
		unlocked_administration[id] = ContentManager.administration[id]
	for id in eligible_services:
		unlocked_services[id] = ContentManager.services[id]
	unlocked_buildings_changed.emit()

	for id in eligible_trees:
		unlocked_trees[id] = ContentManager.trees[id]
	for id in eligible_vegetation:
		unlocked_vegetation[id] = ContentManager.vegetation[id]
	for id in eligible_decoration:
		unlocked_decoration[id] = ContentManager.decoration[id]
	for id in eligible_fixtures:
		unlocked_fixtures[id] = ContentManager.fixtures[id]
	unlocked_scenery_changed.emit()
		
	for id in eligible_products:
		unlocked_products[id] = ContentManager.products[id]
	unlocked_products_changed.emit()
