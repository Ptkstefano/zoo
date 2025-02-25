extends PanelContainer

var enclosure_scene : Enclosure

func _ready() -> void:
	%GoToEnclosureButton.pressed.connect(on_go_to_enclosure_button)
	%EnclosureIDLabel.text = str(tr('UI_MGMT_ENCLOSURE_COUNT')) + str(enclosure_scene.id)
	if enclosure_scene.enclosure_species:
		%AnimalSpeciesLabel.text = tr(enclosure_scene.enclosure_species.tr_name)
	%AnimalCountLabel.text = str(tr('UI_MGMT_ANIMAL_COUNT')) + str(enclosure_scene.enclosure_animals.size())
	
	if enclosure_scene in ZooManager.enclosures_needing_work:
		%AwaitingVisitLabel.text = tr('UI_MGMT_EXPECTING_ZOOKEEPER')

func on_go_to_enclosure_button():
	SignalBus.move_camera_to.emit(enclosure_scene.enclosure_central_point)
	SignalBus.open_popup.emit(null, enclosure_scene)
