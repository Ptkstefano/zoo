extends Control

var terrain_res : Resource

signal terrain_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer/Button.pressed.connect(on_terrain_selected)
	%AnimalName.text = terrain_res.name
	%Thumbnail.texture = terrain_res.thumb
	
func on_terrain_selected():
	terrain_selected.emit(terrain_res)
