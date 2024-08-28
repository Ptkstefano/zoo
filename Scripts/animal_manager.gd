extends Node2D

class_name AnimalManager

@export var area_manager : AreaManager
@export var debug_spawn_animal_scene : PackedScene

var animal_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_animal(coordinate):
	## Find what area the player wants to add an animal to
	var tile_coordinate = area_manager.area_layer.local_to_map(coordinate)
	var found_area = area_manager.get_existing_area(tile_coordinate)
	if found_area:
		var spawned_animal = debug_spawn_animal_scene.instantiate()
		spawned_animal.global_position = coordinate
		spawned_animal.area = found_area
		add_child(spawned_animal)
		animal_count += 1
