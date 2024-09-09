extends CanvasLayer

signal path_tool_selected
signal area_tool_selected

var selected_res:
	set(value):
		inputController.selected_res = value
		
var selected_path : path_resource:
	set(value):
		selected_res = value
		
var selected_area : fence_resource:
	set(value):
		selected_res = value
		
var selected_animal : animal_resource:
	set(value):
		selected_res = value
var selected_scenery

var selected_terrain : terrain_resource:
	set(value):
		selected_res = value
		
var selected_building : building_resource:
	set(value):
		selected_res = value
	

var build_mode : bool = false

@export var inputController : InputController

@onready var info_label = %InfoLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%PathTool.pressed.connect(on_path_tool)
	%AreaTool.pressed.connect(on_area_tool)
	%AnimalTool.pressed.connect(on_animal_tool)
	%SceneryTool.pressed.connect(on_scenery_tool)
	%TerrainTool.pressed.connect(on_terrain_tool)
	%BuildingTool.pressed.connect(on_building_tool)
	
	%BuildPanelOpener.pressed.connect(on_open_build_panel)
	
	%BulldozerTool.button_down.connect(on_bulldozer_tool_press)
	%BulldozerTool.button_up.connect(on_bulldozer_tool_release)
	
	%CameraTool.button_down.connect(on_camera_tool_press)
	%CameraTool.button_up.connect(on_camera_tool_release)
	
	%RotateTool.pressed.connect(on_rotate_tool_press)
	
	%BuildTool.pressed.connect(on_build_tool_press)
	
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
	for element in %FenceSelectionContainer.get_children():
		if element:
			element.fence_selected.connect(on_fence_selected)
	for element in %PathSelectionContainer.get_children():
		if element:
			element.path_selected.connect(on_path_selected)
	for element in %BuildingSelectionContainer.get_children():
		if element:
			element.building_selected.connect(on_building_selected)
			
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
	elif inputController.current_tool == inputController.TOOLS.AREA:
		if inputController.is_bulldozing:
			info_label.text = 'Removing fence'
			return
		info_label.text = 'Building fence'
		return
	elif inputController.current_tool == inputController.TOOLS.SCENERY:
		if inputController.is_bulldozing:
			info_label.text = 'Removing scenery'
			return
		info_label.text = 'Placing scenery'
		return
	elif inputController.current_tool == inputController.TOOLS.TERRAIN:
		info_label.text = 'Adding terrain'
		return
	elif inputController.current_tool == inputController.TOOLS.BUILDING:
		info_label.text = 'Placing building'
		return

func deselect_main():
	for button in $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer.get_children():
		if button is Button:
			inputController.current_tool = inputController.TOOLS.NONE
			button.set_pressed_no_signal(false)
			
func close_selection_submenu():
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
	
func on_fence_selected(fence_res):
	hide_side_panel()
	%ConstructionSidePanel.show()
	inputController.current_tool = inputController.TOOLS.AREA
	selected_res = fence_res
	
func on_path_selected(path_res):
	hide_side_panel()
	%ConstructionSidePanel.show()
	inputController.current_tool = inputController.TOOLS.PATH
	selected_res = path_res
	
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
		build_mode = true
	else:
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
	if tool == inputController.TOOLS.AREA:
		%AreaMenu.show()
	if tool == inputController.TOOLS.ANIMAL:
		%AnimalMenu.show()
	if tool == inputController.TOOLS.SCENERY:
		%SceneryMenu.show()
	if tool == inputController.TOOLS.TERRAIN:
		%TerrainMenu.show()
	if tool == inputController.TOOLS.BUILDING:
		%BuildingMenu.show()
	if tool == inputController.TOOLS.BULLDOZER:
		return

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
	inputController.build_building()
	

func on_path_tool():
	on_tool_selected(inputController.TOOLS.PATH)
func on_area_tool():
	on_tool_selected(inputController.TOOLS.AREA)
func on_animal_tool():
	on_tool_selected(inputController.TOOLS.ANIMAL)
func on_terrain_tool():
	on_tool_selected(inputController.TOOLS.TERRAIN)
func on_scenery_tool():
	on_tool_selected(inputController.TOOLS.SCENERY)
func on_building_tool():
	on_tool_selected(inputController.TOOLS.BUILDING)
