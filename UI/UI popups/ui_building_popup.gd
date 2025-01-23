extends CanvasLayer

var building_node

signal popup_closed

func _ready() -> void:
	if building_node is Shelter:
		%BuildingName.text = building_node.shelter_res.name
	else:
		%BuildingName.text = building_node.building_res.name
	%CloseButton.pressed.connect(on_popup_closed)
	%DeleteButton.pressed.connect(on_remove_building)
	
func on_popup_closed():
	popup_closed.emit()

	
func on_remove_building():
	building_node.remove_building()
	popup_closed.emit()
	queue_free()
