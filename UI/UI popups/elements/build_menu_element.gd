extends Control

var resource

signal element_selected

func _ready() -> void:
	if !resource:
		return
	gui_input.connect(on_gui_input)
	if resource.thumbnail:
		%Thumbnail.texture = resource.thumbnail
	else:
		%Name.text = tr(resource.tr_name)

func on_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			element_selected.emit(self)
			modulate = Color.RED
		if event.double_tap:
			print('DOUBLE TAP')
			
func deselect():
	modulate = Color.WHITE
