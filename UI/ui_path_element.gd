extends Control

var path_res : path_resource
var type 

signal path_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = path_res.type
	$PanelContainer/Button.pressed.connect(on_path_selected)
	%Name.text = path_res.name
	%Thumbnail.texture = path_res.thumb
	
func on_path_selected():
	path_selected.emit(path_res)
