extends Node

@export var ui_shop_popup : PackedScene
@export var ui_animal_popup : PackedScene

var opened_popup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.detectable_element_clicked.connect(on_detectable_element_selected)
	pass # Replace with function body.


func on_detectable_element_selected(detector_pos, element):
	if opened_popup != null:
		opened_popup.queue_free()
		opened_popup = null
	if element is animal:
		open_animal_popup(element, detector_pos)

func open_building_popup(building_node):
	opened_popup = ui_shop_popup.instantiate()
	opened_popup.building_node = building_node
	add_child(opened_popup)

func open_animal_popup(animal_node, detector_pos):
	opened_popup = ui_animal_popup.instantiate()
	opened_popup.animal_scene = animal_node
	add_child(opened_popup)
