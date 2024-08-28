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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func deselect():
	for button in $VBoxContainer/PanelContainer/MarginContainer/HBoxContainer.get_children():
		if button is Button:
			print('deselect')
			inputController.current_tool = inputController.TOOLS.NONE
			button.set_pressed_no_signal(false)

func on_path_tool():
	if inputController.current_tool == inputController.TOOLS.PATH:
		deselect()
	else:
		inputController.current_tool = inputController.TOOLS.PATH

func on_area_tool():
	if inputController.current_tool == inputController.TOOLS.AREA:
		deselect()
	else:
		inputController.current_tool = inputController.TOOLS.AREA

func on_animal_tool():
	if inputController.current_tool == inputController.TOOLS.ANIMAL:
		deselect()
	else:
		inputController.current_tool = inputController.TOOLS.ANIMAL
		
func on_scenery_tool():
	if inputController.current_tool == inputController.TOOLS.SCENERY:
		deselect()
	else:
		inputController.current_tool = inputController.TOOLS.SCENERY
