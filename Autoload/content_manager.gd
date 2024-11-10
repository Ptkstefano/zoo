extends Node
	
var animals = {}
	
func _ready():
	# Path to the folder with the resources
	load_all_resources()

func load_all_resources() -> void:
	var dir = DirAccess.open("res://Animals/AnimalResources/")
	if dir:
		for file in dir.get_files():
			animals[file] = ResourceLoader.load(dir.get_current_dir() + "/" + file)
