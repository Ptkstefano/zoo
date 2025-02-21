extends Control

class_name UI_TerrainElement

var terrain_res : terrain_resource

signal terrain_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if terrain_res:
		%Button.pressed.connect(on_terrain_selected)
		%TerrainName.text = tr(terrain_res.tr_name)
		%Thumbnail.texture = terrain_res.thumb
		%TerrainCost.text = Helpers.money_text(terrain_res.cost)
	
func on_terrain_selected():
	terrain_selected.emit(terrain_res)
