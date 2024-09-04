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
	var neighbors = []
	for coord in coords:
		terrain_layer.set_cell(coord, 0, selected_res.atlas)
		for neighbor in Helpers.get_adjacent(coord):
			if neighbor not in neighbors:
				if neighbor not in coords:
					neighbors.append(neighbor)

	apply_wang(coords, selected_res)

func apply_wang(coords, selected_res):
	remove_wang(coords, selected_res)
	for coord in coords:
		var i = 0
		for neighbor in Helpers.get_adjacent(coord):
			var neighbor_y = terrain_layer.get_cell_atlas_coords(neighbor).y
			if neighbor_y != selected_res.atlas.y:
				if i == 0:
					$"../TileMap/TerrainLayer/TerrainWang_E".set_cell(coord, 0, Vector2(4, neighbor_y))
					$"../TileMap/TerrainLayer/TerrainWang_W".set_cell(neighbor, 0, Vector2(2, selected_res.atlas.y))
				if i == 1:
					$"../TileMap/TerrainLayer/TerrainWang_S".set_cell(coord, 0, Vector2(3, neighbor_y))
					$"../TileMap/TerrainLayer/TerrainWang_N".set_cell(neighbor, 0, Vector2(1, selected_res.atlas.y))
				if i == 2:
					$"../TileMap/TerrainLayer/TerrainWang_W".set_cell(coord, 0, Vector2(2, neighbor_y))
					$"../TileMap/TerrainLayer/TerrainWang_E".set_cell(neighbor, 0, Vector2(4, selected_res.atlas.y))
				if i == 3:
					$"../TileMap/TerrainLayer/TerrainWang_N".set_cell(coord, 0, Vector2(1, neighbor_y))
					$"../TileMap/TerrainLayer/TerrainWang_S".set_cell(neighbor, 0, Vector2(3, selected_res.atlas.y))
			i += 1
	
	

func remove_wang(coords, selected_res):
	for coord in coords:
		## Clear the wang of changed cells
		$"../TileMap/TerrainLayer/TerrainWang_E".set_cell(coord)
		$"../TileMap/TerrainLayer/TerrainWang_S".set_cell(coord)
		$"../TileMap/TerrainLayer/TerrainWang_W".set_cell(coord)
		$"../TileMap/TerrainLayer/TerrainWang_N".set_cell(coord)
		## Clear the wang of nerby cells, but only relevant directions:
		var neighbords = Helpers.get_adjacent(coord)
		$"../TileMap/TerrainLayer/TerrainWang_E".set_cell(neighbords[2])
		$"../TileMap/TerrainLayer/TerrainWang_S".set_cell(neighbords[3])
		$"../TileMap/TerrainLayer/TerrainWang_W".set_cell(neighbords[0])
		$"../TileMap/TerrainLayer/TerrainWang_N".set_cell(neighbords[1])
		
		
		
