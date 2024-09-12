extends Node

@export var ui_shop_popup : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open_building_popup(building_node):
	var new_popup = ui_shop_popup.instantiate()
	new_popup.building_node = building_node
	add_child(new_popup)
