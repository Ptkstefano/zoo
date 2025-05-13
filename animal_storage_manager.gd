extends Node

## stores an array for each species_key
var stored_animals := {}

var available_animals_in_store = {}

var renew_timer_default_wait_time :int = 3600
var loaded_wait_time : int = renew_timer_default_wait_time

signal stored_animals_updated
signal store_animals_updated

## This is being called from the main function
func start() -> void:
	SignalBus.animal_placed.connect(animal_placed)
	SignalBus.animal_bought.connect(on_animal_bought)
	%RenewTimer.start(loaded_wait_time) ## Update with save data
	%RenewTimer.timeout.connect(renew_available_store_animals)
	if available_animals_in_store.is_empty():
		renew_available_store_animals()

func create_animal(animal_res : animal_resource):
	var data = {}
	data['id'] = ZooManager.generate_animal_id()
	data['animal_res'] = animal_res
	data['animal_gender'] = randi_range(0,1)
	data['animal_color_variation'] = randi_range(1, animal_res.possible_sprite_variations)
	data['months_of_life'] = animal_res.months_to_adulthood + int((randf_range(0.05, 0.3) * animal_res.months_of_expected_lifetime))
	
	var instance = StoredAnimal.new()
	instance.create_new_animal(data)
	return instance
	
func add_animal_data(animal_data: StoredAnimal) -> void:
	if !stored_animals.keys().has(animal_data.animal_res.id):
		stored_animals[animal_data.animal_res.id] = []
	stored_animals[animal_data.animal_res.id].append(animal_data)
	stored_animals_updated.emit()
	
func on_animal_bought(animal):
	available_animals_in_store[animal.animal_res.id].erase(animal)
	add_animal_data(animal)
	

func animal_placed(animal_id : int):
	for key in stored_animals:
		for animal in stored_animals[key]:
			if animal.id == animal_id:
				stored_animals[key].erase(animal)
				
	stored_animals_updated.emit()
	#SignalBus.open_box.emit(IdRefs.UI_BOXES.ANIMAL_STORAGE)

func get_animal_data(id: int) -> StoredAnimal:
	return stored_animals.get(id)

func remove_animal_data(animal : StoredAnimal) -> void:
	stored_animals[animal.animal_res.id].erase(animal)
	stored_animals_updated.emit()

func get_all_animal_data() -> Array:
	return stored_animals.values()

func renew_available_store_animals():
	var rarity_weight = {
		IdRefs.ANIMAL_RARITIES.COMMON: 10,
		IdRefs.ANIMAL_RARITIES.UNCOMMON: 4,
		IdRefs.ANIMAL_RARITIES.RARE: 1,
	}
	
	var eligible_animals = []
	for animal in ResearchManager.unlocked_animals.keys():
		for i in rarity_weight[ContentManager.animals[animal].rarity]:
			eligible_animals.append(ContentManager.animals[animal])
			
	available_animals_in_store.clear()
			
	for i in 5:
		var random_animal = eligible_animals.pick_random()
		if random_animal.id not in available_animals_in_store.keys():
			available_animals_in_store[random_animal.id] = []
		var new_animal = create_animal(random_animal)
		available_animals_in_store[random_animal.id].append(new_animal)
		
	%RenewTimer.start(renew_timer_default_wait_time)
	store_animals_updated.emit()
	
func add_store_animal_data(animal : StoredAnimal):
	if animal.animal_res.id not in available_animals_in_store.keys():
		available_animals_in_store[animal.animal_res.id] = []
	available_animals_in_store[animal.animal_res.id].append(animal)
	
func get_renew_store_time_left():
	return int(%RenewTimer.time_left)
