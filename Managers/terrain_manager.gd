extends Node2D

class_name TerrainManager

@onready var terrain_layer = $"../TileMap/TerrainLayer"

@export var available_terrains : Array[terrain_resource]

@onready var terrain_menu = %TerrainSelectionContainer
@export var ui_terrain_element : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.load_terrain.connect(build_terrain)
	update_terrain_menu()


func update_terrain_menu():
	for child in terrain_menu.get_children():
		child.queue_free()
		
	for terrain_res in available_terrains:
		var element = ui_terrain_element.instantiate()
		element.terrain_res = terrain_res
		terrain_menu.add_child(element)
		
	$"../UI".update_ui()

func build_terrain(coords, atlas_y):
	var neighbors = []
	for coord in coords:
		terrain_layer.set_cell(coord, 0, Vector2(0, atlas_y))
		for neighbor in Helpers.get_adjacent(coord):
			if neighbor not in neighbors:
				if neighbor not in coords:
					neighbors.append(neighbor)
					
	apply_wang(coords, atlas_y)
	TileMapRef.update_enclosures(coords)
	if GameManager.game_running:
		SignalBus.save_terrain_changes.emit(coords, atlas_y)
	
	
func get_terrain_coverage(cells):
	var terrain_coverage = {}
	var total_cells = cells.size()
	for cell in cells:
		var y_coord = $"../TileMap/TerrainLayer".get_cell_atlas_coords(cell).y
		if y_coord in terrain_coverage:
			terrain_coverage[y_coord] += 1
		else:
			terrain_coverage[y_coord] = 1
	for key in terrain_coverage.keys():
		terrain_coverage[key] = float(terrain_coverage[key]) / total_cells * 100
		
	return terrain_coverage
	
func apply_wang(coords, atlas_y):
	remove_wang(coords)
	for coord in coords:
		var i = 0
		for neighbor in Helpers.get_adjacent(coord):
			var neighbor_y = terrain_layer.get_cell_atlas_coords(neighbor).y
			if neighbor_y != atlas_y:
				if i == 0:
					$"../TileMap/TerrainLayer/TerrainWang_E".set_cell(coord, 0, Vector2(4, neighbor_y))
					$"../TileMap/TerrainLayer/TerrainWang_W".set_cell(neighbor, 0, Vector2(2, atlas_y))
				if i == 1:
					$"../TileMap/TerrainLayer/TerrainWang_S".set_cell(coord, 0, Vector2(3, neighbor_y))
					$"../TileMap/TerrainLayer/TerrainWang_N".set_cell(neighbor, 0, Vector2(1, atlas_y))
				if i == 2:
					$"../TileMap/TerrainLayer/TerrainWang_W".set_cell(coord, 0, Vector2(2, neighbor_y))
					$"../TileMap/TerrainLayer/TerrainWang_E".set_cell(neighbor, 0, Vector2(4, atlas_y))
				if i == 3:
					$"../TileMap/TerrainLayer/TerrainWang_N".set_cell(coord, 0, Vector2(1, neighbor_y))
					$"../TileMap/TerrainLayer/TerrainWang_S".set_cell(neighbor, 0, Vector2(3, atlas_y))
			i += 1
	


func remove_wang(coords):
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
		
		
		
