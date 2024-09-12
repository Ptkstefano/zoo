extends Control

var resource : Resource

signal scenery_selected

var scenery_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer/Button.pressed.connect(on_scenery_selected)
	%BuildingName.text = resource.name
	%Thumbnail.texture = resource.thumb
	
func on_scenery_selected():
	scenery_selected.emit(resource, scenery_type)
