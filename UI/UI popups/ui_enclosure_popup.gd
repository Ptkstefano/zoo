extends Control

@export var animal_in_enclosure_element : PackedScene

var enclosure : Enclosure

signal popup_closed

func _ready() -> void:
	%Enclosure.text = 'Enclosure #' + str(enclosure.id)
	%CloseButton.pressed.connect(popup_closed.emit)
	for animal in enclosure.enclosure_animals:
		var element = animal_in_enclosure_element.instantiate()
		element.animal_scene = animal
		%AnimalInEnclosureList.add_child(element)
		
