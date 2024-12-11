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
		if inputController.is_bulldozing:
			text = 'Removing path'
			return
		text = 'Building path'
		return
	elif inputController.current_tool == inputController.TOOLS.ENCLOSURE:
		if inputController.is_bulldozing:
			text = 'Removing enclosure'
			return
		text = 'Building enclosure'
		return
	elif inputController.current_tool == inputController.TOOLS.TREE:
		if inputController.is_bulldozing:
			text = 'Removing scenery'
			return
		text = 'Placing single tree'
		return
	elif inputController.current_tool == inputController.TOOLS.VEGETATION:
		if inputController.is_bulldozing:
			text = 'Removing scenery'
			return
		text = 'Placing vegetation'
		return
	elif inputController.current_tool == inputController.TOOLS.DECORATION:
		if inputController.is_bulldozing:
			text = 'Removing scenery'
			return
		text = 'Placing decoration'
		return
	elif inputController.current_tool == inputController.TOOLS.TERRAIN:
		text = 'Adding terrain'
		return
	elif inputController.current_tool == inputController.TOOLS.WATER:
		if inputController.is_bulldozing:
			text = 'Removing lake'
			return
		text = 'Placing lake'
		return
	elif inputController.current_tool == inputController.TOOLS.BUILDING:
		text = 'Placing building'
		return
