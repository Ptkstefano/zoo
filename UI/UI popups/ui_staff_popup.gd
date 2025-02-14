extends Control

var staff_scene : Staff

signal popup_closed

func _ready() -> void:
	%DebugPathfinding.pressed.connect(staff_scene.toggle_pathfinding)
	%DebugBecomeQuestGiver.pressed.connect(staff_scene.on_staff_giving_quest)
	%CloseButton.pressed.connect(popup_closed.emit)
	if staff_scene.staff_type == IdRefs.STAFF_TYPES.ZOOKEEPER_UNIQUE:
		%FireStaff.queue_free()
	else:
		%FireStaff.pressed.connect(staff_scene.fire_staff)
