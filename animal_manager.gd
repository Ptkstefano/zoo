extends Node2D

@onready var general_area_tilemap = $"../TileMap/AreaLayer"
@export var debug_spawn_animal_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_animal(coordinate):
	## Find what area the player wants to add an animal to
	var tile_coordinate = general_area_tilemap.local_to_map(coordinate)
	var found_area = $"../AreaManager".get_existing_area(tile_coordinate)
	if found_area:
		var spawned_animal = debug_spawn_animal_scene.instantiate()
		var areas = $"../AreaManager".get_children()
		var random_area = areas.pick_random()
		spawned_animal.global_position = coordinate
		spawned_animal.area = random_area
		random_area.add_child(spawned_animal)
