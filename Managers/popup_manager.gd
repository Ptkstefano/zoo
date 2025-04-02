extends Node

@export var ui_shop_popup : PackedScene
@export var ui_building_popup : PackedScene
@export var ui_animal_popup : PackedScene
@export var ui_peep_group_popup : PackedScene
@export var ui_enclosure_popup : PackedScene
@export var ui_staff_popup : PackedScene
@export var ui_construction_menu_popup : PackedScene

@export var ui_mgmt_box : PackedScene
@export var ui_world_map_box : PackedScene

@export var ui_animal_info_popup : PackedScene

var opened_popup

func _ready() -> void:
	SignalBus.open_popup.connect(open_popup) ## Popups are associated to something in the gamemap such as peeps or animals
	SignalBus.open_popup_with_data.connect(open_popup_with_data)
	SignalBus.open_box.connect(open_box) ## Boxes are more general popups that do not reference something in the gamemap
	SignalBus.open_construction_menu.connect(open_construction_menu)


func open_construction_menu(menu_type):
	if opened_popup != null:
		opened_popup.queue_free()

	opened_popup = ui_construction_menu_popup.instantiate()
	opened_popup.menu_type = menu_type
	opened_popup.popup_closed.connect(close_popup)
	add_child(opened_popup)


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
	if element is Staff:
		open_staff_popup(element)
	if element is Building:
		if element.is_shop:
			open_shop_popup(element)
		else:
			open_building_popup(element)

func close_popup():
	if opened_popup is ConstructionMenu:
		SignalBus.construction_menu_closed.emit()
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
	if box == IdRefs.UI_BOXES.WORLD_MAP:
		open_world_map_box()
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
	opened_popup = ui_mgmt_box.instantiate()
	opened_popup.popup_closed.connect(close_popup)
	add_child(opened_popup)

func open_world_map_box():
	opened_popup = ui_world_map_box.instantiate()
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

func open_staff_popup(staff : Staff):
	if staff.is_quest_giver:
		staff.on_staff_stop_giving_quest()
	else:
		opened_popup = ui_staff_popup.instantiate()
		opened_popup.staff_scene = staff
		opened_popup.popup_closed.connect(close_popup)
		add_child(opened_popup)
