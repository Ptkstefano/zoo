extends Node
	
@export var animal_files : Array[animal_resource]

var animals = {}
	
func _ready():
	load_all_resources()


func load_all_resources() -> void:
	for file in animal_files:
		animals[file.name] = file
	
