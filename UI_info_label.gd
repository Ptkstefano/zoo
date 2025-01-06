extends Label

@export var inputController : InputController

func _process(delta: float) -> void:
	if inputController.current_tool == inputController.TOOLS.NONE:
		visible = false
	else:
		visible = true
		update_tool_label()

func update_tool_label():
	if !inputController.selected_res:
		return
	if inputController.is_camera_tool_selected:
		text = 'Moving camera freely'
		return
	if inputController.current_tool == inputController.TOOLS.ANIMAL:
		text = 'Placing ' + inputController.selected_res.name
		return
	elif inputController.current_tool == inputController.TOOLS.PATH:
		text = 'Building path'
		return
	elif inputController.current_tool == inputController.TOOLS.ENCLOSURE:
		text = 'Building enclosure'
		return
	elif inputController.current_tool == inputController.TOOLS.TREE:
		text = 'Placing single tree'
		return
	elif inputController.current_tool == inputController.TOOLS.VEGETATION:
		text = 'Placing vegetation'
		return
	elif inputController.current_tool == inputController.TOOLS.DECORATION:
		text = 'Placing decoration'
		return
	elif inputController.current_tool == inputController.TOOLS.TERRAIN:
		text = 'Adding terrain'
		return
	elif inputController.current_tool == inputController.TOOLS.WATER:
		text = 'Placing lake'
		return
	elif inputController.current_tool == inputController.TOOLS.BUILDING:
		text = 'Placing building'
		return
