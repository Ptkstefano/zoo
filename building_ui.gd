extends CanvasLayer

signal path_tool_selected
signal area_tool_selected

@export var inputController : InputController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%PathTool.pressed.connect(on_path_tool)
	%AreaTool.pressed.connect(on_area_tool)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_path_tool():
	inputController.current_tool = inputController.TOOLS.PATH

func on_area_tool():
	inputController.current_tool = inputController.TOOLS.AREA
