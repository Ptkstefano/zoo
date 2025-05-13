extends Control

@export var stored_animal_element : PackedScene

signal popup_closed


func _ready() -> void:
	%CloseMenu.pressed.connect(popup_closed.emit)
	
	for child in %ElementList.get_children():
		child.queue_free()
	
	for species_key in AnimalStorageManager.stored_animals.keys():
		for animal in AnimalStorageManager.stored_animals[species_key]:
			var element = stored_animal_element.instantiate()
			element.stored_animal = animal
			element.place_animal.connect(place_animal)
			element.release_animal.connect(release_animal)
			%ElementList.add_child(element)
		
func place_animal(animal):
	SignalBus.tool_selected.emit(IdRefs.TOOLS.ANIMAL, animal)
	popup_closed.emit()
	
func release_animal(animal):
	AnimalStorageManager.remove_animal_data(animal)
	_ready()
