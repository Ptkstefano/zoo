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
		
	if enclosure.is_enclosure_in_work_queue:
		%ZookeeperVisit.text = 'Enclosure expecting zookeeper visit'
	else:
		%ZookeeperVisit.text = ''

	%RequestZookeeper.pressed.connect(on_request_zookeeper)
	
func on_request_zookeeper():
	enclosure.add_to_work_queue()
