extends Control

var building_res : building_resource

signal building_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if building_res:
		$PanelContainer/Button.pressed.connect(on_building_selected)
		%BuildingName.text = building_res.name
		%Thumbnail.texture = building_res.thumb
	
func on_building_selected():
	building_selected.emit(building_res)
