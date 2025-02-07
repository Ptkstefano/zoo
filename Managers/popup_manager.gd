extends Node

@export var ui_shop_popup : PackedScene
@export var ui_building_popup : PackedScene
@export var ui_animal_popup : PackedScene
@export var ui_mgmt_popup : PackedScene
@export var ui_peep_group_popup : PackedScene
@export var ui_enclosure_popup : PackedScene

@export var ui_animal_info_popup : PackedScene

@export var ui_confirmation_popup : PackedScene

var opened_popup

func _ready() -> void:
	SignalBus.open_popup.connect(open_popup)
	SignalBus.open_popup_with_data.connect(open_popup_with_data)
	SignalBus.open_box.connect(open_box)
	SignalBus.open_confirmation_popup.connect(open_confirmation_popup)


func open_popup_with_data(type, data):
	if opened_popup != null:
		opened_popup.queue_free()
		opened_popup = null
	if type == 'AnimalInfo':
		open_animal_info_popup(data)
		

func open_popup(detector_pos, element):
	if opened_popup != null:
		opened_popup.queue_free()
		opened_popup = null
	if element is Animal:
		open_animal_popup(element, detector_pos)
	if element is PeepGroup:
		open_peepgroup_popup(element)
	if opened_popup != null:
		SignalBus.ui_visibility.emit(false)
	if element is Shelter:
		open_building_popup(element)
	if element is EnclosureFence or element is Enclosure:
		open_enclosure_popup(element)
	if element is Building:
		if element.is_shop:
			open_shop_popup(element)
		else:
			open_building_popup(element)

func open_confirmation_popup(callback, popup_text, data):
	var confirmation_popup = ui_confirmation_popup.instantiate()
	confirmation_popup.callback = callback
	confirmation_popup.text = popup_text
	confirmation_popup.data = data
	add_child(confirmation_popup)

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

func open_building_popup(building_node):
	opened_popup = ui_building_popup.instantiate()
	opened_popup.building_node = building_node
	opened_popup.popup_closed.connect(close_popup)
	add_child(opened_popup)

func open_animal_info_popup(data):
	opened_popup = ui_animal_info_popup.instantiate()
	opened_popup.animal_res = data['resource']
	opened_popup.popup_closed.connect(close_popup)
	add_child(opened_popup)

func open_enclosure_popup(element):
	opened_popup = ui_enclosure_popup.instantiate()
	if element is EnclosureFence:
		opened_popup.enclosure = element.enclosure_scene
	if element is Enclosure:
		opened_popup.enclosure = element
	opened_popup.popup_closed.connect(close_popup)
	add_child(opened_popup)
