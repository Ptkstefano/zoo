extends Control

var terrain_res : terrain_resource

signal terrain_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PanelContainer/Button.pressed.connect(on_terrain_selected)
	%TerrainName.text = terrain_res.name
	%Thumbnail.texture = terrain_res.thumb
	
func on_terrain_selected():
	terrain_selected.emit(terrain_res)
