extends Control

var enclosure_res : fence_resource

signal enclosure_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer/Button.pressed.connect(on_enclosure_selected)
	%EnclosureName.text = enclosure_res.name
	%Thumbnail.texture = enclosure_res.thumb
	
func on_enclosure_selected():
	enclosure_selected.emit(enclosure_res)
