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
	

@export var inputController : InputController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%PathTool.pressed.connect(on_path_tool)
	%AreaTool.pressed.connect(on_area_tool)
	%AnimalTool.pressed.connect(on_animal_tool)
	%SceneryTool.pressed.connect(on_scenery_tool)
	%TerrainTool.pressed.connect(on_terrain_tool)
	%BulldozerTool.pressed.connect(on_bulldozer_tool)
	#selected_path = %PathSelectionContainer.get_child(0).path_res
	#selected_area = %FenceSelectionContainer.get_child(0).fence_res
	#selected_animal = %AnimalSelectionContainer.get_child(0).animal_res
	#selected_terrain = %TerrainSelectionContainer.get_child(0).terrain_res

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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

func deselect_main():
	for button in $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer.get_children():
		if button is Button:
			inputController.current_tool = inputController.TOOLS.NONE
			button.set_pressed_no_signal(false)
			
func hide_selection_menu():
	for child in %SelectionMenu.get_children():
		if child is PanelContainer:
			child.hide()

func on_animal_selected(animal_res):
	selected_res = animal_res

func on_terrain_selected(terrain_res):
	selected_res = terrain_res
	
func on_fence_selected(fence_res):
	selected_res = fence_res
	
func on_path_selected(path_res):
	selected_res = path_res


func on_tool_selected(tool):
	hide_selection_menu()
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

func on_bulldozer_tool():
	on_tool_selected(inputController.TOOLS.BULLDOZER)
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
