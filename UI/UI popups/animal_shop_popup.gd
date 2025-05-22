extends Control

@export var store_animal_element : PackedScene

signal popup_closed

func _ready() -> void:
	%CloseMenu.pressed.connect(popup_closed.emit)
	
	AnimalStorageManager.store_animals_updated.connect(on_store_animals_updated)
	
	for child in %ElementList.get_children():
		child.queue_free()
	
	for species_key in AnimalStorageManager.available_animals_in_store.keys():
		for animal in AnimalStorageManager.available_animals_in_store[species_key]:
			var element = store_animal_element.instantiate()
			element.stored_animal = animal
			element.buy_animal.connect(buy_animal)
			%ElementList.add_child(element)
		
func _process(delta: float) -> void:
	%TimeLabel.text = Helpers.format_seconds_to_clock(AnimalStorageManager.get_renew_store_time_left())
		
func buy_animal(animal):
	SignalBus.animal_bought.emit(animal)
	
func on_store_animals_updated():
	_ready()
