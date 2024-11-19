extends Control

var animal_res : animal_resource

signal animal_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if animal_res:
		%Button.pressed.connect(on_animal_selected)
		%AnimalName.text = animal_res.name
		%Thumbnail.texture = animal_res.thumb
		%AnimalCost.text = Helpers.money_text(animal_res.cost)
	
func on_animal_selected():
	animal_selected.emit(animal_res)
