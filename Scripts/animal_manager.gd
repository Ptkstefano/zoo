extends Node2D

class_name AnimalManager

@export var available_animals : Array[animal_resource]

@export var enclosure_manager : EnclosureManager
@export var animal_scene : PackedScene

@onready var animal_menu = %AnimalSelectionContainer
@export var ui_animal_element : PackedScene
var animal_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_animal_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_animal_menu():
	for child in animal_menu.get_children():
		child.queue_free()
		
	for animal_res in available_animals:
		var element = ui_animal_element.instantiate()
		element.animal_res = animal_res
		animal_menu.add_child(element)
		
	$"../../UI".update_ui()


func spawn_animal(coordinate, animal_res):
		
	## Find what enclosure the player wants to add an animal to
	var cell = TileMapRef.local_to_map(coordinate)
	var found_enclosure = enclosure_manager.get_enclosure_by_cell(cell)
	if !found_enclosure:
		return
		
	if found_enclosure.enclosure_species == null:
		found_enclosure.enclosure_species = animal_res
	else:
		if found_enclosure.enclosure_species != animal_res:
			return
		
	var spawned_animal = animal_scene.instantiate()
	spawned_animal.initialize_animal(animal_res, coordinate, found_enclosure)
	spawned_animal.animal_removed.connect(despawn_animal)
	add_child(spawned_animal)
	Effects.wobble(spawned_animal)
	found_enclosure.add_animal(spawned_animal)
	animal_count += 1
	
func despawn_animal(animal):
	animal_count -= 1
