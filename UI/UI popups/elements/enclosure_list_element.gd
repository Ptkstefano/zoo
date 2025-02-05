extends PanelContainer

var enclosure_scene : Enclosure

func _ready() -> void:
	%GoToEnclosureButton.pressed.connect(on_go_to_enclosure_button)
	%EnclosureIDLabel.text = 'Enclosure #' + str(enclosure_scene.id)
	if enclosure_scene.enclosure_species:
		%AnimalSpeciesLabel.text = str(enclosure_scene.enclosure_species.name)
	%AnimalCountLabel.text = 'Number of animals: ' + str(enclosure_scene.enclosure_animals.size())
	
	if enclosure_scene in ZooManager.enclosures_needing_work:
		%AwaitingVisitLabel.text = str('Enclosure awaiting zookeeper visit')

func on_go_to_enclosure_button():
	SignalBus.move_camera_to.emit(enclosure_scene.enclosure_central_point)
	SignalBus.open_popup.emit(null, enclosure_scene)
