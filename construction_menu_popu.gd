extends Control

class_name ConstructionMenu

@export var element_card : PackedScene



var menu_type

var selected_element

enum CATEGORIES{
	PATH,
	FIXTURE,
	DECORATION,
	FENCE,
	SHELTER,
	TREE,
	VEGETATION,
	ROCK,
	EATERY,
	RESTAURANT,
	ADMINISTRATION,
	SERVICE
}

var current_category = null

signal popup_closed

func _ready() -> void:
	%InfoContainer.hide()
	%ConfirmButton.pressed.connect(on_confirm_button_pressed)
	%CloseMenu.pressed.connect(popup_closed.emit)
	
	%PathButton.pressed.connect(change_category.bind(CATEGORIES.PATH))
	%FixtureButton.pressed.connect(change_category.bind(CATEGORIES.FIXTURE))
	%DecorationButton.pressed.connect(change_category.bind(CATEGORIES.DECORATION))
	%FenceButton.pressed.connect(change_category.bind(CATEGORIES.FENCE))
	%ShelterButton.pressed.connect(change_category.bind(CATEGORIES.SHELTER))
	%TreeButton.pressed.connect(change_category.bind(CATEGORIES.TREE))
	%VegetationButton.pressed.connect(change_category.bind(CATEGORIES.VEGETATION))
	%RockButton.pressed.connect(change_category.bind(CATEGORIES.ROCK))
	%EateryButton.pressed.connect(change_category.bind(CATEGORIES.EATERY))
	%RestaurantButton.pressed.connect(change_category.bind(CATEGORIES.RESTAURANT))
	%AdministrationButton.pressed.connect(change_category.bind(CATEGORIES.ADMINISTRATION))
	%ServiceButton.pressed.connect(change_category.bind(CATEGORIES.SERVICE))
	
	
	
	
	add_category_buttons()
	add_elements()

func select_element(element):
	if selected_element:
		selected_element.deselect()
		
	%InfoContainer.show()
	selected_element = element

func add_category_buttons():
	
	for button in %CategoryButtons.get_children():
		button.hide()
	
	if menu_type == IdRefs.CONSTRUCTION_MENUS.PATH:
		current_category = CATEGORIES.PATH
		%PathButton.show()
		%FixtureButton.show()
		%DecorationButton.show()
	
	if menu_type == IdRefs.CONSTRUCTION_MENUS.ENCLOSURE:
		current_category = CATEGORIES.FENCE
		%FenceButton.show()
		%ShelterButton.show()
		
	if menu_type == IdRefs.CONSTRUCTION_MENUS.SCENERY:
		current_category = CATEGORIES.TREE
		%TreeButton.show()
		%VegetationButton.show()
		%RockButton.show()
		
	if menu_type == IdRefs.CONSTRUCTION_MENUS.BUILDING:
		current_category = CATEGORIES.EATERY
		%EateryButton.show()
		%RestaurantButton.show()
		%AdministrationButton.show()
		%ServiceButton.show()

func change_category(category):
	current_category = category
	add_elements()

func add_elements():
	for element in %ElementList.get_children():
		element.queue_free()

	if current_category == CATEGORIES.PATH:
		for entry in ResearchManager.unlocked_paths:
			create_element(ContentManager.paths[entry])
			
	if current_category == CATEGORIES.FIXTURE:
		for entry in ResearchManager.unlocked_fixtures:
			create_element(ContentManager.fixtures[entry])
			
	if current_category == CATEGORIES.DECORATION:
		for entry in ResearchManager.unlocked_decoration:
			create_element(ContentManager.decoration[entry])

	if current_category == CATEGORIES.FENCE:
		for entry in ContentManager.fences:
			create_element(ContentManager.fences[entry])
			
	if current_category == CATEGORIES.SHELTER:
		for entry in ContentManager.shelters:
			create_element(ContentManager.shelters[entry])
			
	if current_category == CATEGORIES.TREE:
		for entry in ResearchManager.unlocked_trees:
			create_element(ContentManager.trees[entry])
			
	if current_category == CATEGORIES.VEGETATION:
		for entry in ResearchManager.unlocked_vegetation:
			create_element(ContentManager.vegetation[entry])
			
	if current_category == CATEGORIES.ROCK:
		return
		
	if current_category == CATEGORIES.EATERY:
		for entry in ResearchManager.unlocked_eateries:
			create_element(ContentManager.eateries[entry])
			
	if current_category == CATEGORIES.RESTAURANT:
		for entry in ResearchManager.unlocked_restaurants:
			create_element(ContentManager.restaurants[entry])
			
	if current_category == CATEGORIES.SERVICE:
		for entry in ResearchManager.unlocked_services:
			create_element(ContentManager.services[entry])
			
	if current_category == CATEGORIES.ADMINISTRATION:
		for entry in ResearchManager.unlocked_administration:
			create_element(ContentManager.administration[entry])

	if menu_type == IdRefs.CONSTRUCTION_MENUS.TERRAIN:
		for entry in ContentManager.terrains:
			create_element(ContentManager.terrains[entry])
			
	if menu_type == IdRefs.CONSTRUCTION_MENUS.LAKE:
		for entry in ResearchManager.unlocked_lakes:
			create_element(ContentManager.lakes[entry])

func create_element(resource):
	var element = element_card.instantiate()
	element.resource = resource
	element.element_selected.connect(select_element)
	%ElementList.add_child(element)


func on_confirm_button_pressed():
	if selected_element.resource is fence_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.ENCLOSURE, selected_element.resource)
	if selected_element.resource is shelter_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.SHELTER, selected_element.resource)
	if selected_element.resource is path_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.PATH, selected_element.resource)
	if selected_element.resource is fixture_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.FIXTURE, selected_element.resource)
	if selected_element.resource is decoration_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.DECORATION, selected_element.resource)
	if selected_element.resource is tree_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.TREE, selected_element.resource)
	if selected_element.resource is vegetation_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.VEGETATION, selected_element.resource)
	if selected_element.resource is rock_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.ROCK, selected_element.resource)
	if selected_element.resource is building_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.BUILDING, selected_element.resource)
	if selected_element.resource is terrain_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.TERRAIN, selected_element.resource)
	if selected_element.resource is lake_resource:
		SignalBus.tool_selected.emit(IdRefs.TOOLS.WATER, selected_element.resource)
		
	hide()
