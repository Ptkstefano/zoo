extends Control

class_name UI_PathElement

var path_res : path_resource
var type 

signal path_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if path_res:
		type = path_res.type
		%Button.pressed.connect(on_path_selected)
		%PathName.text = tr(path_res.tr_name)
		%Thumbnail.texture = path_res.thumb
		%PathCost.text = Helpers.money_text(path_res.cost)
	
func on_path_selected():
	path_selected.emit(path_res)
