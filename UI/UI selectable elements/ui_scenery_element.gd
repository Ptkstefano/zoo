extends Control

class_name UI_SceneryElement

var resource : Resource

signal scenery_selected

var scenery_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Button.pressed.connect(on_scenery_selected)
	%Scenery.text = resource.name
	%Thumbnail.texture = resource.thumb
	%SceneryCost.text = Helpers.money_text(resource.cost)
	
func on_scenery_selected():
	scenery_selected.emit(resource, scenery_type)
