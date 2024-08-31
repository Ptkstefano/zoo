extends Node2D

class_name TerrainManager

@onready var terrain_layer = $"../TileMap/TerrainLayer"

@export var available_terrains : Array[terrain_resource]

@onready var terrain_menu = %TerrainSelectionContainer
@export var ui_terrain_element : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_terrain_menu()


func update_terrain_menu():
	for child in terrain_menu.get_children():
		child.queue_free()
		
	for terrain_res in available_terrains:
		var element = ui_terrain_element.instantiate()
		element.terrain_res = terrain_res
		terrain_menu.add_child(element)
		
	$"../UI".update_ui()

func build_terrain(coords, selected_res : terrain_resource):
	for coord in coords:
		terrain_layer.set_cell(coord, 0, selected_res.atlas)
