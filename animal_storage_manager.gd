extends Node

## stores an array for each species_key
var stored_animals := {}

func _ready() -> void:
	SignalBus.animal_placed.connect(animal_placed)

func create_animal(animal_res : animal_resource):
	var data = {}
	data['id'] = ZooManager.generate_animal_id()
	data['animal_res'] = animal_res
	data['animal_gender'] = randi_range(0,1)
	data['animal_color_variation'] = randi_range(1, animal_res.possible_sprite_variations)
	data['months_of_life'] = animal_res.months_to_adulthood + int((randf_range(0.05, 0.3) * animal_res.months_of_expected_lifetime))
	
	var instance = StoredAnimal.new()
	instance.create_new_animal(data)
	add_animal_data(instance)
	
func add_animal_data(animal_data: StoredAnimal) -> void:
	if !stored_animals.keys().has(animal_data.animal_res.id):
		stored_animals[animal_data.animal_res.id] = []
	stored_animals[animal_data.animal_res.id].append(animal_data)

func animal_placed(animal_id : int):
	for key in stored_animals:
		for animal in stored_animals[key]:
			if animal.id == animal_id:
				stored_animals[key].erase(animal)
	#SignalBus.open_box.emit(IdRefs.UI_BOXES.ANIMAL_STORAGE)

func get_animal_data(id: int) -> StoredAnimal:
	return stored_animals.get(id)

func remove_animal_data(id: int) -> void:
	stored_animals.erase(id)

func get_all_animal_data() -> Array:
	return stored_animals.values()
