extends Node

@export var ui_shop_popup : PackedScene
@export var ui_animal_popup : PackedScene
@export var ui_mgmt_popup : PackedScene
@export var ui_peep_group_popup : PackedScene

var opened_popup

func _ready() -> void:
	SignalBus.open_popup.connect(open_popup)
	SignalBus.open_box.connect(open_box)

func open_popup(detector_pos, element):
	if opened_popup != null:
		opened_popup.queue_free()
		opened_popup = null
	if element is Animal:
		open_animal_popup(element, detector_pos)
	if element is Shop:
		open_shop_popup(element)
	if element is PeepGroup:
		open_peepgroup_popup(element)
	if opened_popup != null:
		SignalBus.ui_visibility.emit(false)

func close_popup():
	if opened_popup != null:
		opened_popup.queue_free()
		opened_popup = null
		SignalBus.ui_visibility.emit(true)

func open_box(box):
	if opened_popup != null:
		opened_popup.queue_free()
		opened_popup = null
	if box == IdRefs.UI_BOXES.MANAGEMENT:
		open_mgmt_box()
	if opened_popup != null:
		SignalBus.ui_visibility.emit(false)

func open_shop_popup(shop_node):
	opened_popup = ui_shop_popup.instantiate()
	opened_popup.building_id = shop_node.building_res_id
	opened_popup.shop_node = shop_node
	opened_popup.popup_closed.connect(close_popup)
	add_child(opened_popup)

func open_animal_popup(animal_node, detector_pos):
	opened_popup = ui_animal_popup.instantiate()
	opened_popup.animal_scene = animal_node
	opened_popup.popup_closed.connect(close_popup)
	add_child(opened_popup)

func open_mgmt_box():
	opened_popup = ui_mgmt_popup.instantiate()
	opened_popup.popup_closed.connect(close_popup)
	add_child(opened_popup)

func open_peepgroup_popup(peepgroup_node):
	opened_popup = ui_peep_group_popup.instantiate()
	opened_popup.peep_group_node = peepgroup_node
	opened_popup.popup_closed.connect(close_popup)
	add_child(opened_popup)
