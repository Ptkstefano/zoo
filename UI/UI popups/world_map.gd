extends Node2D

signal expedition_chosen

func _ready() -> void:
	for child in %Icons.get_children():
		child.input_event.connect(on_icon_clicked.bind(child))
	
func on_icon_clicked(viewport, event : InputEvent, shape, node):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			expedition_chosen.emit(node.expedition_resource)
