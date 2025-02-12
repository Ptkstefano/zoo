extends Control

class_name UI_AnimalElement

var animal_res : animal_resource

signal animal_selected

@export var selected_element_style : StyleBox
@export var deselected_element_style : StyleBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if animal_res:
		#%Button.pressed.connect(on_animal_selected)
		%AnimalName.text = animal_res.name
		%Thumbnail.texture = animal_res.thumb
		gui_input.connect(on_gui)
		%AnimalCost.text = Helpers.money_text(animal_res.cost)
		SignalBus.ui_element_selected.connect(deselect)
	
func on_animal_selected():
	animal_selected.emit(animal_res)

func on_gui(event):
	if event is InputEventScreenTouch:
		if !event.pressed:
			animal_selected.emit(animal_res)
			select()

func select():
	SignalBus.ui_element_selected.emit()
	add_theme_stylebox_override('panel', selected_element_style)
	
	
func deselect():
	add_theme_stylebox_override('panel', deselected_element_style)
	
