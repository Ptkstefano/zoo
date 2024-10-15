extends Node

@export var ui_shop_popup : PackedScene
@export var ui_animal_popup : PackedScene

var opened_popup

func _ready() -> void:
	SignalBus.clickable_element_clicked.connect(on_detectable_element_selected)

func on_detectable_element_selected(detector_pos, element):
	if opened_popup != null:
		opened_popup.queue_free()
		opened_popup = null
	if element is Animal:
		open_animal_popup(element, detector_pos)
	if element is Shop:
		open_shop_popup(element)

func open_shop_popup(shop_node):
	print(shop_node)
	opened_popup = ui_shop_popup.instantiate()
	opened_popup.shop_node = shop_node
	add_child(opened_popup)

func open_animal_popup(animal_node, detector_pos):
	opened_popup = ui_animal_popup.instantiate()
	opened_popup.animal_scene = animal_node
	add_child(opened_popup)
