extends Control

class_name UI_ShelterElement

var shelter_res : shelter_resource

signal shelter_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if shelter_res:
		$PanelContainer/Button.pressed.connect(on_shelter_selected)
		%BuildingName.text = shelter_res.name
		%Thumbnail.texture = shelter_res.thumb
	
func on_shelter_selected():
	shelter_selected.emit(shelter_res)
