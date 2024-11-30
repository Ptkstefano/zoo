extends CanvasLayer

signal path_tool_selected
signal enclosure_tool_selected

var selected_res:
	set(value):
		selected_res = value
		inputController.selected_res = value
		
var build_mode : bool = false

@export var inputController : InputController

@onready var money_label = %MoneyLabel

func _ready() -> void:
	SignalBus.ui_visibility.connect(ui_visibility)
	
	%RightMenuToggle.toggled.connect(on_right_menu_toggle) 
	
	## DEBUG menu show and hide
	%RightMenuToggle.button_down.connect(right_menu_down)
	%RightMenuToggle.button_up.connect(right_menu_up)
	%DebugTimer.timeout.connect(debug_timer_timeout)
	
	%DebugScreen.hide()
	
	#%DebugToggle.pressed.connect(on_debug_toggle)
	%SaveGame.pressed.connect(on_save_game)
	
	%MgmtMenu.pressed.connect(on_box_pressed.bind(IdRefs.UI_BOXES.MANAGEMENT))
	
	%BuildPanelOpener.pressed.connect(on_open_build_panel)
	
	%BulldozerTool.button_down.connect(on_bulldozer_tool.bind(true))
	%BulldozerTool.button_up.connect(on_bulldozer_tool.bind(false))
	
	%CameraTool.button_down.connect(on_camera_tool.bind(true))
	%CameraTool.button_up.connect(on_camera_tool.bind(false))
	
	%RotateTool.pressed.connect(on_rotate_tool_press)
	
	%BuildTool.pressed.connect(on_build_tool_press)
	%PathTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.PATH))
	%EnclosureTool.pressed.connect((open_subpanel.bind('EnclosureSubpanel')))
	
	%EnclosureFenceTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.ENCLOSURE))
	%EnclosureShelterTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.SHELTER))
	
	%AnimalTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.ANIMAL))
	%SceneryTool.pressed.connect(open_subpanel.bind('ScenerySubpanel'))
	%TerrainTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.TERRAIN))
	%BuildingTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.BUILDING))
	%WaterTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.WATER))
	%EntranceTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.ENTRANCE))
	
	%SceneryTreesTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.TREE))
	%SceneryDecorationTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.SCENERY))
	%SceneryVegetationTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.VEGETATION))
	%SceneryFixtureTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.FIXTURE)) 
	%SceneryRockTool.pressed.connect(on_tool_selected.bind(inputController.TOOLS.ROCK)) 
	
	SignalBus.money_changed.connect(on_money_changed)
	
	inputController.building_placed.connect(on_building_placed)
	inputController.building_built.connect(on_building_built)
	
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
	for element in %RockSelectionContainer.get_children():
		if element:
			element.scenery_selected.connect(on_scenery_selected)

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
	
func ui_visibility(value : bool):
	var tween = get_tree().create_tween()
	if value:
		tween.tween_property($MarginContainer, "modulate:a", 1.0, 0.25)
	else:
		tween.tween_property($MarginContainer, "modulate:a", 0.0, 0.25)
	
	
	
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
	if type == 'rock':
		inputController.current_tool = inputController.TOOLS.ROCK
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
	if tool == inputController.TOOLS.BULLDOZER:
		return
	if tool == inputController.TOOLS.WATER:
		%ConstructionSidePanel.show()
		inputController.current_tool = inputController.TOOLS.WATER
	if tool == inputController.TOOLS.ENTRANCE:
		%EnclosureSubpanel.show()
		%EnclosureMenu.show()
		inputController.current_tool = inputController.TOOLS.ENTRANCE

func on_bulldozer_tool(value : bool):
	inputController.is_bulldozing = value
	
func on_camera_tool(value : bool):
	inputController.is_camera_tool_selected = value
	
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
	
func on_box_pressed(box):
	SignalBus.open_box.emit(box)

func on_save_game():
	SignalBus.save_game.emit()

func on_money_changed(amount):
	money_label.text = "$ " + str(amount)


func right_menu_down():
	%DebugTimer.start()
func right_menu_up():
	%DebugTimer.stop()
func debug_timer_timeout():
	if %DebugScreen.visible:
		%DebugScreen.hide()
	else:
		%DebugScreen.show()
	
