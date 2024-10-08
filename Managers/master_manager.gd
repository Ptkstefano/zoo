extends Node


func _ready() -> void:
	var animal_manager : AnimalManager = get_parent().get_child(2).find_child('Objects').find_child('AnimalManager')
