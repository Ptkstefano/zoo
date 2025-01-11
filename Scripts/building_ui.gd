extends CanvasLayer

signal path_tool_selected
signal enclosure_tool_selected

var selected_res:
	set(value):
		selected_res = value
		inputController.selected_res = value
		
var build_mode : bool = false

@export var inputController : InputController

func _ready() -> void:
	SignalBus.ui_visibility.connect(ui_visibility)
	
	%OptionsMenuToggle.toggled.connect(on_options_menu_toggle) 
	%BuildModeButton.toggled.connect(on_build_mode_toggle)
	
	#%DebugToggle.pressed.connect(on_debug_toggle)
	## Options menu buttons
	%SaveGame.pressed.connect(on_save_game)
	%MgmtMenu.pressed.connect(on_box_pressed.bind(IdRefs.UI_BOXES.MANAGEMENT))
	
	%OptionsMenuToggle.visibility_changed.connect(on_options_menu_toggle_visibility_changed)

	
	## Construction mode buttons
	#%BulldozerTool.button_down.connect(on_bulldozer_tool.bind(true))
	#%BulldozerTool.button_up.connect(on_bulldozer_tool.bind(false))
	%CameraTool.button_down.connect(on_camera_tool.bind(true))
	%CameraTool.button_up.connect(on_camera_tool.bind(false))
	%RotateTool.pressed.connect(on_rotate_tool_press)
	%BuildTool.pressed.connect(on_build_tool_press)
	
	%EnclosureFenceTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.ENCLOSURE))
	%EnclosureShelterTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.SHELTER))
	%PathTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.PATH))
	%EnclosureTool.pressed.connect((open_subpanel.bind('EnclosureSubpanel')))
	%AnimalTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.ANIMAL))
	%SceneryTool.pressed.connect(open_subpanel.bind('ScenerySubpanel'))
	%TerrainTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.TERRAIN))
	#%BuildingTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.BUILDING))
	%BuildingTool.pressed.connect(open_subpanel.bind('BuildingSubpanel'))
	%WaterTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.WATER))
	%EntranceTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.ENTRANCE))
	%SceneryTreesTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.TREE))
	%SceneryDecorationTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.DECORATION))
	%SceneryVegetationTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.VEGETATION))
	%SceneryFixtureTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.FIXTURE)) 
	%SceneryRockTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.ROCK)) 
	%BuildingEateryTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.EATERY)) 
	%BuildingRestaurntTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.RESTAURANT)) 
	%BuildingServicesTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.SERVICE)) 
	%BuildingAdministrationTool.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.ADMINISTRATION)) 
	
	%BulldozerPath.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.BULLDOZER_PATH)) 
	%BulldozerEnclosure.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.BULLDOZER_ENCLOSURE)) 
	%BulldozerTrees.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.BULLDOZER_SCENERY)) 
	%BulldozerVegetation.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.BULLDOZER_SCENERY)) 
	%BulldozerFixture.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.BULLDOZER_SCENERY)) 
	%BulldozerDecoration.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.BULLDOZER_SCENERY)) 
	%BulldozerRock.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.BULLDOZER_SCENERY)) 
	%BulldozerLake.pressed.connect(on_tool_menu_selected.bind(inputController.TOOLS.BULLDOZER_WATER)) 
	
	%VegetationBrushCheckBox.toggled.connect(on_vegetation_brush_toggle)
	%FixtureFreeCheckBox.toggled.connect(on_free_fixture_placement_toggle)
	
	%BulldozerTreeCheckBox.toggled.connect(on_scenery_bulldozer_filter_toggle)
	%BulldozerVegetationCheckBox.toggled.connect(on_scenery_bulldozer_filter_toggle)
	%BulldozerFixtureCheckBox.toggled.connect(on_scenery_bulldozer_filter_toggle)
	%BulldozerDecorationCheckBox.toggled.connect(on_scenery_bulldozer_filter_toggle)
	%BulldozerRockCheckBox.toggled.connect(on_scenery_bulldozer_filter_toggle)
	
	%MaleGenderButton.toggled.connect(on_animal_gender_toggle.bind(IdRefs.ANIMAL_GENDERS.MALE))
	%FemaleGenderButton.toggled.connect(on_animal_gender_toggle.bind(IdRefs.ANIMAL_GENDERS.FEMALE))
	
	%ToolDeselect.pressed.connect(on_tool_deselect)
	
	## DEBUG menu show and hide
	%DebugScreen.hide()
	%OptionsMenuToggle.button_down.connect(right_menu_down)
	%OptionsMenuToggle.button_up.connect(right_menu_up)
	%DebugTimer.timeout.connect(debug_timer_timeout)
	
	inputController.building_placed.connect(on_building_placed)
	inputController.building_built.connect(on_building_built)
	
	reset_ui()
	get_tree().get_root().size_changed.connect(resize_ui)
	resize_ui()
	hide_selection_menu()

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
	for element in %EaterySelectionContainer.get_children():
		if element:
			element.building_selected.connect(on_building_selected)
	for element in %RestaurantSelectionContainer.get_children():
		if element:
			element.building_selected.connect(on_building_selected)
	for element in %ServicesSelectionContainer.get_children():
		if element:
			element.building_selected.connect(on_building_selected)
	for element in %AdministrationSelectionContainer.get_children():
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
	for element in %RockSelectionContainer.get_children():
		if element:
			element.scenery_selected.connect(on_scenery_selected)
	for element in %LakeSelectionContainer.get_children():
		if element:
			element.lake_selected.connect(on_lake_selected)

func on_options_menu_toggle(toggled):
	if toggled:
		%OptionsDropMenu.visible = true
	else:
		%OptionsDropMenu.visible = false

func on_debug_toggle():
	if %DebugScreen.visible:
		%DebugScreen.visible = false
	else:
		%DebugScreen.visible = true
	
func ui_visibility(value : bool):
	var tween = get_tree().create_tween()
	if value:
		tween.tween_property(%MainMargin, "modulate:a", 1.0, 0.25)
	else:
		tween.tween_property(%MainMargin, "modulate:a", 0.0, 0.25)
	
	
	
	#$"MarginContainer/Top-Left".visible = value
	#$"MarginContainer/Top-Right".visible = value
	#$MarginContainer/Bottom.visible = value
	

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
	%SidePanel.visible = false
	%BuildingSidePanel.visible = false

func show_selection_menu():
	%SelectionMenu.visible = true

func on_animal_selected(animal_res):
	open_tool_info_panel('PlacingAnimalInfoContainer')
	if inputController.selected_animal_gender == IdRefs.ANIMAL_GENDERS.MALE:
		%MaleGenderButton.button_pressed = true
	else:
		%FemaleGenderButton.button_pressed = true
	%SidePanel.show()
	%InfoBorder.apply_color(ColorRefs.construction_yellow)
	inputController.current_tool = inputController.TOOLS.ANIMAL
	selected_res = animal_res

func on_terrain_selected(terrain_res):
	hide_side_panel()
	open_tool_info_panel('PlacingTerrainInfoContainer')
	%SidePanel.show()
	%InfoBorder.apply_color(ColorRefs.construction_yellow)
	inputController.current_tool = inputController.TOOLS.TERRAIN
	selected_res = terrain_res
	
func on_enclosure_selected(enclosure_res):
	hide_side_panel()
	open_tool_info_panel('BuildingEnclosureInfoContainer')
	%SidePanel.show()
	%InfoBorder.apply_color(ColorRefs.construction_yellow)
	inputController.current_tool = inputController.TOOLS.ENCLOSURE
	selected_res = enclosure_res
	
func on_shelter_selected(shelter_res):
	hide_side_panel()
	open_tool_info_panel('PlacingShelterInfoContainer')
	%SidePanel.show()
	%InfoBorder.apply_color(ColorRefs.construction_yellow)
	%BuildingSidePanel.show()
	inputController.current_tool = inputController.TOOLS.SHELTER
	selected_res = shelter_res
	
func on_path_selected(path_res):
	hide_side_panel()
	open_tool_info_panel('BuildingPathInfoContainer')
	%SidePanel.show()
	%InfoBorder.apply_color(ColorRefs.construction_yellow)
	inputController.current_tool = inputController.TOOLS.PATH
	selected_res = path_res
	
func on_scenery_selected(scenery_res, type):
	hide_side_panel()
	%SidePanel.show()
	%InfoBorder.apply_color(ColorRefs.construction_yellow)
	if type == 'tree':
		inputController.current_tool = inputController.TOOLS.TREE
		open_tool_info_panel('PlacingSceneryInfoContainer')
	if type == 'vegetation':
		inputController.current_tool = inputController.TOOLS.VEGETATION
		open_tool_info_panel('PlacingVegetationInfoContainer')
	if type == 'decoration':
		inputController.current_tool = inputController.TOOLS.DECORATION
		open_tool_info_panel('PlacingSceneryInfoContainer')
	if type == 'fixture':
		inputController.current_tool = inputController.TOOLS.FIXTURE
		open_tool_info_panel('PlacingFixtureInfoContainer')
	if type == 'rock':
		inputController.current_tool = inputController.TOOLS.ROCK
		open_tool_info_panel('PlacingSceneryInfoContainer')
	selected_res = scenery_res
	
func on_building_selected(building_res):
	hide_side_panel()
	%SidePanel.show()
	%InfoBorder.apply_color(ColorRefs.construction_yellow)
	open_tool_info_panel('PlacingBuildingInfoContainer')
	if building_res.building_menu == IdRefs.BUILDING_MENU.EATERY:
		inputController.current_tool = inputController.TOOLS.EATERY
	if building_res.building_menu == IdRefs.BUILDING_MENU.RESTAURANT:
		inputController.current_tool = inputController.TOOLS.RESTAURANT
	if building_res.building_menu == IdRefs.BUILDING_MENU.SERVICE:
		inputController.current_tool = inputController.TOOLS.SERVICE
	if building_res.building_menu == IdRefs.BUILDING_MENU.ADMINISTRATION:
		inputController.current_tool = inputController.TOOLS.ADMINISTRATION
	selected_res = building_res
	
func on_lake_selected(lake_res):
	hide_side_panel()
	open_tool_info_panel('PlacingLakeInfoContainer')
	%SidePanel.show()
	%InfoBorder.apply_color(ColorRefs.construction_yellow)
	inputController.current_tool = inputController.TOOLS.WATER
	selected_res = lake_res
	
func on_building_placed():
	%SidePanel.show()
	%InfoBorder.apply_color(ColorRefs.construction_yellow)
	%BuildingSidePanel.show()
	
func on_building_built():
	hide_side_panel()
	inputController.current_tool = inputController.TOOLS.NONE

func on_tool_menu_selected(tool):
	on_tool_deselect()
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
		%DecorationMenu.show()
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
	if tool == inputController.TOOLS.ROCK:
		%ScenerySubpanel.show()
		%RockMenu.show()
	if tool == inputController.TOOLS.FIXTURE:
		%ScenerySubpanel.show()
		%FixtureMenu.show()
	if tool == inputController.TOOLS.EATERY:
		%BuildingSubpanel.show()
		%EateryMenu.show()
	if tool == inputController.TOOLS.RESTAURANT:
		%BuildingSubpanel.show()
		%RestaurantMenu.show()
	if tool == inputController.TOOLS.SERVICE:
		%BuildingSubpanel.show()
		%ServicesMenu.show()
	if tool == inputController.TOOLS.ADMINISTRATION:
		%BuildingSubpanel.show()
		%AdministrationMenu.show()
	if tool == inputController.TOOLS.WATER:
		%LakeMenu.show()
		
		
	if tool in inputController.bulldozer_tools:
		%SidePanel.show()
		inputController.current_tool = tool
		%InfoBorder.apply_color(ColorRefs.bulldozer_red)
		if tool == inputController.TOOLS.BULLDOZER_PATH:
			on_scenery_bulldozer_filter_toggle(false)
			open_tool_info_panel('BulldozingPathInfoContainer')
		if tool == inputController.TOOLS.BULLDOZER_ENCLOSURE:
			on_scenery_bulldozer_filter_toggle(false)
			open_tool_info_panel('BulldozingEnclosureInfoContainer')
		if tool == inputController.TOOLS.BULLDOZER_SCENERY:
			on_scenery_bulldozer_filter_toggle(false)
			open_tool_info_panel('BulldozingSceneryInfoContainer')
		if tool == inputController.TOOLS.BULLDOZER_WATER:
			open_tool_info_panel('BulldozingLakeInfoContainer')
		
	if tool == inputController.TOOLS.ENTRANCE:
		%EnclosureSubpanel.show()
		%EnclosureMenu.show()
		inputController.current_tool = inputController.TOOLS.ENTRANCE
	
func on_camera_tool(value : bool):
	inputController.is_camera_tool_selected = value
	if value:
		%InfoBorder.apply_color(ColorRefs.neutral_white)
	else:
		if inputController.current_tool in inputController.bulldozer_tools:
			%InfoBorder.apply_color(ColorRefs.bulldozer_red)
		else:
			%InfoBorder.apply_color(ColorRefs.construction_yellow)
	
func on_rotate_tool_press():
	inputController.rotate_building_toggle()
	
func on_build_tool_press():
	if selected_res is building_resource:
		inputController.build_building()
	if selected_res is shelter_resource:
		inputController.build_shelter()
	if selected_res is decoration_resource:
		inputController.build_decoration()
	
func open_subpanel(subpanel_name):
	close_selection_submenu()
	%ScenerySubpanel.show()
	for children in %Subpanel.get_children():
		if children.name != subpanel_name:
			children.hide()
		else:
			children.show()
			if subpanel_name == 'EnclosureSubpanel':
				%EnclosureSubpanel.show()
	
func on_box_pressed(box):
	SignalBus.open_box.emit(box)

func on_save_game():
	SignalBus.save_game.emit()

func right_menu_down():
	%DebugTimer.start()
func right_menu_up():
	%DebugTimer.stop()
func debug_timer_timeout():
	if %DebugScreen.visible:
		%DebugScreen.hide()
	else:
		%DebugScreen.show()
	
func on_build_mode_toggle(toggle):
	if toggle:
		%ConstructionToolsContainer.show()
		%InfoBorder.show()
		%MainOptions.hide()
		%GridLayer.show()
		build_mode = true
	if !toggle:
		%ConstructionToolsContainer.hide()
		%InfoBorder.hide()
		%MainOptions.show()
		%GridLayer.hide()
		hide_side_panel()
		build_mode = false
		selected_res = null
		on_tool_deselect()
		SignalBus.clear_highlight.emit()
		
	
func on_options_menu_toggle_visibility_changed():
	if !%OptionsMenuToggle.is_visible_in_tree():
		%OptionsMenuToggle.button_pressed = false
		%OptionsDropMenu.visible = false
		


func resize_ui():
	if DisplayServer.window_get_size().y < 1080:
		%ConstructionMain.scale = Vector2(0.60, 0.60)
		#%"Top-Right".scale = Vector2(0.75, 0.75)
		%SelectionMenu.scale = Vector2(0.75, 0.75)
		
		%"Top-Right-Options".scale = Vector2(0.75, 0.75)
		%BuildModeButton.scale = Vector2(0.75, 0.75)
		%ConstructionButtonSeparator.add_theme_constant_override("separation", 150)
		
	else:
		%ConstructionMain.scale = Vector2(1, 1)
		#%"Top-Right".scale = Vector2(1, 1)
		%SelectionMenu.scale = Vector2(1, 1)
		%"Top-Right-Options".scale = Vector2(1, 1)
		%BuildModeButton.scale = Vector2(1, 1)
		%ConstructionButtonSeparator.add_theme_constant_override("separation", 125)

func open_tool_info_panel(panel_name):
	%ToolPanel.hide()
	%ToolInfoPanel.show()
	%ToolInfoContainer.find_child(panel_name).show()
	## For some reason, showing the panel containter before the content bugs the panel size
	%ToolInfoPanelContainer.show()
	
func on_tool_deselect():
	%InfoBorder.apply_color(ColorRefs.neutral_white)
	inputController.current_tool = InputController.TOOLS.NONE
	%ToolInfoPanel.hide()
	%ToolPanel.show()
	%SidePanel.hide()
	%BuildingSidePanel.hide()
	for child in %ToolInfoContainer.get_children():
		if child is PanelContainer:
			child.hide()
	%ToolInfoPanelContainer.hide()

func reset_ui():
	hide_side_panel()
	on_tool_deselect()
	%ConstructionToolsContainer.hide()
	%MainOptions.show()
	%OptionsDropMenu.hide()
	%InfoBorder.hide()

func on_vegetation_brush_toggle(value):
	inputController.vegetation_brush = value

func on_free_fixture_placement_toggle(value):
	inputController.free_placing_fixture = value

func on_scenery_bulldozer_filter_toggle(value):
	var bulldozer_filters = {
		17: %BulldozerTreeCheckBox.button_pressed,
		18: %BulldozerVegetationCheckBox.button_pressed,
		19: %BulldozerFixtureCheckBox.button_pressed,
		20: %BulldozerDecorationCheckBox.button_pressed,
		21: %BulldozerRockCheckBox.button_pressed,
	}
	inputController.set_bulldozer_filters(bulldozer_filters)

func on_animal_gender_toggle(value, gender):
	if gender == IdRefs.ANIMAL_GENDERS.MALE:
		%MaleGenderButton.set_pressed_no_signal(true)
		%FemaleGenderButton.set_pressed_no_signal(false)
		inputController.selected_animal_gender = gender
	else:
		%MaleGenderButton.set_pressed_no_signal(false)
		%FemaleGenderButton.set_pressed_no_signal(true)
		inputController.selected_animal_gender = gender
