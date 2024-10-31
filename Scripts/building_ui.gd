extends CanvasLayer

signal path_tool_selected
signal enclosure_tool_selected

@export var mgmg_popup : PackedScene

var selected_res:
	set(value):
		selected_res = value
		inputController.selected_res = value
		
#var selected_path : path_resource:
	#set(value):
		#selected_res = value
		#
#var selected_enclosure : fence_resource:
	#set(value):
		#selected_res = value
		#
#var selected_animal : animal_resource:
	#set(value):
		#selected_res = value
#var selected_scenery
#
#var selected_terrain : terrain_resource:
	#set(value):
		#selected_res = value
		#
#var selected_building : building_resource:
	#set(value):
		#selected_res = value
	

var build_mode : bool = false

@export var inputController : InputController

@onready var info_label = %InfoLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%PathTool.pressed.connect(on_path_tool)
	%EnclosureTool.pressed.connect(on_enclosure_tool)
	
	%RightMenuToggle.toggled.connect(on_right_menu_toggle)
	%DebugToggle.pressed.connect(on_debug_toggle)
	
	%MgmtMenu.pressed.connect(on_popup_pressed.bind('mgmt'))
	
	%AnimalTool.pressed.connect(on_animal_tool)
	%SceneryTool.pressed.connect(on_scenery_tool)
	%TerrainTool.pressed.connect(on_terrain_tool)
	%BuildingTool.pressed.connect(on_building_tool)
	%WaterTool.pressed.connect(on_water_tool)
	
	%BuildPanelOpener.pressed.connect(on_open_build_panel)
	
	%BulldozerTool.button_down.connect(on_bulldozer_tool_press)
	%BulldozerTool.button_up.connect(on_bulldozer_tool_release)
	
	%CameraTool.button_down.connect(on_camera_tool_press)
	%CameraTool.button_up.connect(on_camera_tool_release)
	
	%RotateTool.pressed.connect(on_rotate_tool_press)
	
	%BuildTool.pressed.connect(on_build_tool_press)
	
	%EnclosureFenceTool.pressed.connect(on_enclosure_fence_tool_press)
	%EnclosureShelterTool.pressed.connect(on_enclosure_shelter_tool_press)
	
	%SceneryTreesTool.pressed.connect(on_scenery_trees_tool_press)
	%SceneryDecorationTool.pressed.connect(on_scenery_decorations_tool_press)
	%SceneryVegetationTool.pressed.connect(on_scenery_vegetations_tool_press)
	%SceneryFixtureTool.pressed.connect(on_scenery_fixtures_tool_press) 
	
	inputController.building_placed.connect(on_building_placed)
	inputController.building_built.connect(on_building_built)
	
	hide_selection_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_info_label()

func update_ui():
	for element in %AnimalSelectionContainer.get_children():
		if element:
			element.animal_selected.connect(on_animal_selected)
	for element in %TerrainSelectionContainer.get_children():
		if element:
			element.terrain_selected.connect(on_terrain_selected)
	for element in %EnclosureSelectionContainer.get_children():
		if element:
			element.enclosure_selected.connect(on_enclosure_selected)
	for element in %ShelterSelectionContainer.get_children():
		if element:
			element.shelter_selected.connect(on_shelter_selected)
	for element in %PathSelectionContainer.get_children():
		if element:
			element.path_selected.connect(on_path_selected)
	for element in %BuildingSelectionContainer.get_children():
		if element:
			element.building_selected.connect(on_building_selected)
	for element in %TreesSelectionContainer.get_children():
		if element:
			element.scenery_selected.connect(on_scenery_selected)
	for element in %VegetationSelectionContainer.get_children():
		if element:
			element.scenery_selected.connect(on_scenery_selected)
	for element in %FixtureSelectionContainer.get_children():
		if element:
			element.scenery_selected.connect(on_scenery_selected)
	for element in %DecorationSelectionContainer.get_children():
		if element:
			element.scenery_selected.connect(on_scenery_selected)
			
func update_info_label():
	if inputController.current_tool == inputController.TOOLS.NONE:
		%InfoContainer.visible = false
		return
	else:
		%InfoContainer.visible = true
	if inputController.is_camera_tool_selected:
		info_label.text = 'Moving camera freely'
		return
	if inputController.current_tool == inputController.TOOLS.ANIMAL:
		info_label.text = 'Placing animal'
		return
	elif inputController.current_tool == inputController.TOOLS.PATH:
		if inputController.is_bulldozing:
			info_label.text = 'Removing path'
			return
		info_label.text = 'Building path'
		return
	elif inputController.current_tool == inputController.TOOLS.ENCLOSURE:
		if inputController.is_bulldozing:
			info_label.text = 'Removing enclosure'
			return
		info_label.text = 'Building enclosure'
		return
	elif inputController.current_tool == inputController.TOOLS.TREE:
		if inputController.is_bulldozing:
			info_label.text = 'Removing scenery'
			return
		info_label.text = 'Placing single tree'
		return
	elif inputController.current_tool == inputController.TOOLS.VEGETATION:
		if inputController.is_bulldozing:
			info_label.text = 'Removing scenery'
			return
		info_label.text = 'Placing vegetation'
		return
	elif inputController.current_tool == inputController.TOOLS.DECORATION:
		if inputController.is_bulldozing:
			info_label.text = 'Removing scenery'
			return
		info_label.text = 'Placing decoration'
		return
	elif inputController.current_tool == inputController.TOOLS.TERRAIN:
		info_label.text = 'Adding terrain'
		return
	elif inputController.current_tool == inputController.TOOLS.WATER:
		if inputController.is_bulldozing:
			info_label.text = 'Removing lake'
			return
		info_label.text = 'Placing lake'
		return
	elif inputController.current_tool == inputController.TOOLS.BUILDING:
		info_label.text = 'Placing building'
		return

func on_right_menu_toggle(toggled):
	if toggled:
		%DropDownMenu.visible = true
	else:
		%DropDownMenu.visible = false

func on_debug_toggle():
	if %DebugScreen.visible:
		%DebugScreen.visible = false
	else:
		%DebugScreen.visible = true
	

func deselect_main():
	for button in $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer.get_children():
		if button is Button:
			inputController.current_tool = inputController.TOOLS.NONE
			button.set_pressed_no_signal(false)
			
func close_selection_submenu():
	for child in %Subpanel.get_children():
		child.hide()
	for child in %SelectionPanel.get_children():
		if child is PanelContainer:
			child.hide()
			
func hide_selection_menu():
	hide_side_panel()
	%SelectionMenu.visible = false

func hide_side_panel():
	%ConstructionSidePanel.visible = false
	%BuildingSidePanel.visible = false

func show_selection_menu():
	%SelectionMenu.visible = true

func on_animal_selected(animal_res):
	inputController.current_tool = inputController.TOOLS.ANIMAL
	selected_res = animal_res

func on_terrain_selected(terrain_res):
	hide_side_panel()
	%ConstructionSidePanel.show()
	inputController.current_tool = inputController.TOOLS.TERRAIN
	selected_res = terrain_res
	
func on_enclosure_selected(enclosure_res):
	hide_side_panel()
	%ConstructionSidePanel.show()
	inputController.current_tool = inputController.TOOLS.ENCLOSURE
	selected_res = enclosure_res
	
func on_shelter_selected(shelter_res):
	hide_side_panel()
	%BuildingSidePanel.show()
	inputController.current_tool = inputController.TOOLS.SHELTER
	selected_res = shelter_res
	
func on_path_selected(path_res):
	hide_side_panel()
	%ConstructionSidePanel.show()
	inputController.current_tool = inputController.TOOLS.PATH
	selected_res = path_res
	
func on_scenery_selected(scenery_res, type):
	hide_side_panel()
	%ConstructionSidePanel.show()
	if type == 'tree':
		inputController.current_tool = inputController.TOOLS.TREE
	if type == 'vegetation':
		inputController.current_tool = inputController.TOOLS.VEGETATION
	if type == 'decoration':
		inputController.current_tool = inputController.TOOLS.DECORATION
	if type == 'fixture':
		inputController.current_tool = inputController.TOOLS.FIXTURE
	selected_res = scenery_res
	
func on_building_selected(building_res):
	hide_side_panel()
	inputController.current_tool = inputController.TOOLS.BUILDING
	selected_res = building_res
	
func on_building_placed():
	%BuildingSidePanel.show()
	
func on_building_built():
	hide_side_panel()
	inputController.current_tool = inputController.TOOLS.NONE

func on_open_build_panel():
	if !%ToolPanel.visible and !build_mode:
		%ToolPanel.show()
		%Subpanel.show()
		build_mode = true
	else:
		%Subpanel.hide()
		inputController.current_tool = inputController.TOOLS.NONE
		build_mode = false
		%ToolPanel.hide()
		hide_selection_menu()

func on_tool_selected(tool):
	inputController.current_tool = inputController.TOOLS.NONE
	show_selection_menu()
	close_selection_submenu()

	if tool == inputController.TOOLS.PATH:
		%PathMenu.show()
	if tool == inputController.TOOLS.ENCLOSURE:
		%EnclosureSubpanel.show()
		%EnclosureMenu.show()
	if tool == inputController.TOOLS.SHELTER:
		%EnclosureSubpanel.show()
		%ShelterMenu.show()
	if tool == inputController.TOOLS.ANIMAL:
		%AnimalMenu.show()
	if tool == inputController.TOOLS.SCENERY:
		%SceneryMenu.show()
	if tool == inputController.TOOLS.TERRAIN:
		%TerrainMenu.show()
	if tool == inputController.TOOLS.BUILDING:
		%BuildingMenu.show()
	if tool == inputController.TOOLS.TREE:
		%ScenerySubpanel.show()
		%TreesMenu.show()
	if tool == inputController.TOOLS.VEGETATION:
		%ScenerySubpanel.show()
		%VegetationMenu.show()
	if tool == inputController.TOOLS.DECORATION:
		%ScenerySubpanel.show()
		%DecorationMenu.show()
	if tool == inputController.TOOLS.FIXTURE:
		%ScenerySubpanel.show()
		%FixtureMenu.show()
	if tool == inputController.TOOLS.BULLDOZER:
		return
	if tool == inputController.TOOLS.WATER:
		%ConstructionSidePanel.show()
		inputController.current_tool = inputController.TOOLS.WATER

func on_bulldozer_tool_press():
	inputController.is_bulldozing = true
	
func on_bulldozer_tool_release():
	inputController.is_bulldozing = false
	
func on_camera_tool_press():
	inputController.is_camera_tool_selected = true
	
func on_camera_tool_release():
	inputController.is_camera_tool_selected = false
	
func on_rotate_tool_press():
	inputController.rotate_building_toggle()
	
func on_build_tool_press():
	if selected_res is building_resource:
		inputController.build_building()
	if selected_res is shelter_resource:
		inputController.build_shelter()
	
func open_subpanel(subpanel_name):
	%ScenerySubpanel.show()
	for children in %Subpanel.get_children():
		if children.name != subpanel_name:
			children.hide()
		else:
			children.show()
	

func on_path_tool():
	on_tool_selected(inputController.TOOLS.PATH)
func on_enclosure_tool():
	open_subpanel('EnclosureSubpanel')
func on_animal_tool():
	on_tool_selected(inputController.TOOLS.ANIMAL)
func on_terrain_tool():
	on_tool_selected(inputController.TOOLS.TERRAIN)
func on_scenery_tool():
	open_subpanel('ScenerySubpanel')
func on_scenery_trees_tool_press():
	on_tool_selected(inputController.TOOLS.TREE)
func on_scenery_decorations_tool_press():
	on_tool_selected(inputController.TOOLS.DECORATION)
func on_scenery_vegetations_tool_press():
	on_tool_selected(inputController.TOOLS.VEGETATION)
func on_enclosure_fence_tool_press():
	on_tool_selected(inputController.TOOLS.ENCLOSURE)
func on_enclosure_shelter_tool_press():
	on_tool_selected(inputController.TOOLS.SHELTER)
func on_scenery_fixtures_tool_press():
	on_tool_selected(inputController.TOOLS.FIXTURE)
func on_building_tool():
	on_tool_selected(inputController.TOOLS.BUILDING)
func on_water_tool():
	on_tool_selected(inputController.TOOLS.WATER)

func on_popup_pressed(popup):
	var new_popup
	if popup == 'mgmt':
		new_popup = mgmg_popup.instantiate()
	
	if new_popup:
		add_child(new_popup)
	
