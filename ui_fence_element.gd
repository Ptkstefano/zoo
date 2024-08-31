extends Control

var fence_res : fence_resource

signal fence_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer/Button.pressed.connect(on_animal_selected)
	%FenceName.text = fence_res.name
	%Thumbnail.texture = fence_res.thumb
	
func on_animal_selected():
	fence_selected.emit(fence_res)
