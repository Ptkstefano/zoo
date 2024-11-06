extends Area2D

var parent

func _ready() -> void:
	parent = get_parent()
	area_entered.connect(on_clicked)
	
func on_clicked(area):
	SignalBus.open_popup.emit(global_position, parent)
