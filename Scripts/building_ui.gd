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
	
	%BuildPanelOpener.pressed.connect(on_open_build_panel)
	
	%BulldozerTool.button_down.connect(on_bulldozer_tool_press)
	%BulldozerTool.button_up.connect(on_bulldozer_tool_release)
	
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

func update_info_label():
	if inputController.current_tool == inputController.TOOLS.NONE:
		%InfoContainer.visible = false
		return
	else:
		%InfoContainer.visible = true
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
	%BulldozerContainer.visible = false
	%SelectionMenu.visible = false

func show_selection_menu():
	%BulldozerContainer.visible = true
	%SelectionMenu.visible = true

func on_animal_selected(animal_res):
	selected_res = animal_res

func on_terrain_selected(terrain_res):
	selected_res = terrain_res
	
func on_fence_selected(fence_res):
	selected_res = fence_res
	
func on_path_selected(path_res):
	selected_res = path_res

func on_open_build_panel():
	if !%ToolPanel.visible and !build_mode:
		%ToolPanel.show()
		show_selection_menu()
		build_mode = true
	else:
		inputController.current_tool = inputController.TOOLS.NONE
		build_mode = false
		%ToolPanel.hide()
		hide_selection_menu()

func on_tool_selected(tool):
	show_selection_menu()
	close_selection_submenu()
	inputController.current_tool = tool
	if tool == inputController.TOOLS.PATH:
		%PathMenu.show()
		if !selected_path:
			selected_path = %PathSelectionContainer.get_child(0).path_res
	if tool == inputController.TOOLS.AREA:
		%AreaMenu.show()
		if !selected_area:
			selected_area = %FenceSelectionContainer.get_child(0).fence_res
			selected_res
	if tool == inputController.TOOLS.ANIMAL:
		%AnimalMenu.show()
		if !selected_animal:
			selected_animal = %AnimalSelectionContainer.get_child(0).animal_res
			selected_res
	if tool == inputController.TOOLS.SCENERY:
		%SceneryMenu.show()
	if tool == inputController.TOOLS.TERRAIN:
		%TerrainMenu.show()
		if !selected_terrain:
			selected_terrain = %TerrainSelectionContainer.get_child(0).terrain_res
			selected_res

	if tool == inputController.TOOLS.BULLDOZER:
		return

func on_bulldozer_tool_press():
	inputController.is_bulldozing = true
	
func on_bulldozer_tool_release():
	inputController.is_bulldozing = false
	
func on_path_tool():
	if inputController.current_tool == inputController.TOOLS.PATH:
		hide_selection_menu()
		inputController.current_tool = inputController.TOOLS.NONE
		return
	on_tool_selected(inputController.TOOLS.PATH)
	%BulldozerContainer.visible = true
func on_area_tool():
	if inputController.current_tool == inputController.TOOLS.AREA:
		hide_selection_menu()
		inputController.current_tool = inputController.TOOLS.NONE
		return
	on_tool_selected(inputController.TOOLS.AREA)
	%BulldozerContainer.visible = true
func on_animal_tool():
	if inputController.current_tool == inputController.TOOLS.ANIMAL:
		hide_selection_menu()
		inputController.current_tool = inputController.TOOLS.NONE
		return
	on_tool_selected(inputController.TOOLS.ANIMAL)
	%BulldozerContainer.visible = false
func on_terrain_tool():
	if inputController.current_tool == inputController.TOOLS.TERRAIN:
		hide_selection_menu()
		inputController.current_tool = inputController.TOOLS.NONE
		return
	on_tool_selected(inputController.TOOLS.TERRAIN)
	%BulldozerContainer.visible = false
func on_scenery_tool():
	if inputController.current_tool == inputController.TOOLS.SCENERY:
		hide_selection_menu()
		return
	on_tool_selected(inputController.TOOLS.SCENERY)
	%BulldozerContainer.visible = true
