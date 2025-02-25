extends PanelContainer

class_name UI_LakeElement

var lake_res : lake_resource

signal lake_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if lake_res:
		%Button.pressed.connect(on_terrain_selected)
		%TerrainName.text = tr(lake_res.tr_name)
		%Thumbnail.texture = lake_res.thumbnail
	
func on_terrain_selected():
	lake_selected.emit(lake_res)
