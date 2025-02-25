extends Control

class_name UI_BuildingElement

var building_res : building_resource

signal building_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if building_res:
		%Button.pressed.connect(on_building_selected)
		%BuildingName.text = tr(building_res.tr_name)
		%Thumbnail.texture = building_res.thumb
		%BuildingCost.text = Helpers.money_text(building_res.building_cost)
	
func on_building_selected():
	building_selected.emit(building_res)
