extends CanvasLayer

signal path_tool_selected
signal area_tool_selected

@export var inputController : InputController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%PathTool.pressed.connect(on_path_tool)
	%AreaTool.pressed.connect(on_area_tool)
	%AnimalTool.pressed.connect(on_animal_tool)
	%SceneryTool.pressed.connect(on_scenery_tool)
	%TerrainTool.pressed.connect(on_terrain_tool)

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
	inputController.selected_res = animal_res

func on_terrain_selected(terrain_res):
	inputController.selected_res = terrain_res
	
func on_fence_selected(fence_res):
	inputController.selected_res = fence_res

func on_path_tool():
	if inputController.current_tool == inputController.TOOLS.PATH:
		%PathMenu.hide()
		deselect_main()
		hide_selection_menu()
	else:
		hide_selection_menu()
		%PathMenu.show()
		inputController.current_tool = inputController.TOOLS.PATH

func on_area_tool():
	if inputController.current_tool == inputController.TOOLS.AREA:
		%AreaMenu.hide()
		deselect_main()
		hide_selection_menu()
	else:
		hide_selection_menu()
		%AreaMenu.show()
		inputController.current_tool = inputController.TOOLS.AREA

func on_animal_tool():
	if inputController.current_tool == inputController.TOOLS.ANIMAL:
		%AnimalMenu.hide()
		deselect_main()
		hide_selection_menu()
	else:
		hide_selection_menu()
		%AnimalMenu.show()
		inputController.current_tool = inputController.TOOLS.ANIMAL

func on_terrain_tool():
	if inputController.current_tool == inputController.TOOLS.TERRAIN:
		%TerrainMenu.hide()
		deselect_main()
		hide_selection_menu()
	else:
		hide_selection_menu()
		%TerrainMenu.show()
		inputController.current_tool = inputController.TOOLS.TERRAIN


func on_scenery_tool():
	if inputController.current_tool == inputController.TOOLS.SCENERY:
		%SceneryMenu.hide()
		deselect_main()
		hide_selection_menu()
	else:
		hide_selection_menu()
		%SceneryMenu.show()
		inputController.current_tool = inputController.TOOLS.SCENERY
