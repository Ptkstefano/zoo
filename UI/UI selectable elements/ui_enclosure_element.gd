extends Control

class_name UI_EnclosureElement

var enclosure_res : fence_resource

signal enclosure_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if enclosure_res:
		%Button.pressed.connect(on_enclosure_selected)
		%FenceName.text = enclosure_res.name
		%Thumbnail.texture = enclosure_res.thumb
		%FenceCost.text = Helpers.money_text(enclosure_res.segment_cost)
	
func on_enclosure_selected():
	enclosure_selected.emit(enclosure_res)
