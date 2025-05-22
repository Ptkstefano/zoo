extends Node

class_name Quest

var quest_resource : quest_res

var objectives = {}

func _ready() -> void:
	for objective in quest_resource.objectives:
		objectives[objective] = {
			'is_complete': false,
		}
