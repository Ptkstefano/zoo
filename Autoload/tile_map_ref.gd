extends TileMapLayer

var navigation_rid

var occupied_tiles : Array[Vector2i] = []

signal new_occupied_tile

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_terrain_coverage(cells):
	var main_node = get_tree().root.get_node("Main")
	var terrain_manager = main_node.get_node("TerrainManager")
	return terrain_manager.get_terrain_coverage(cells)

func get_water_availability(cells):
	var main_node = get_tree().root.get_node("Main")
	var water_manager = main_node.get_node("Objects").get_node('WaterManager')
	return water_manager.get_water_availability(cells)

func get_path_atlas(cell):
	var main_node = get_tree().root.get_node("Main")
	var path_layer = main_node.get_node("TileMap").get_node('PathLayer') as TileMapLayer
	return path_layer.get_cell_atlas_coords(cell)

func update_enclosures(cells):
	var main_node = get_tree().root.get_node("Main")
	var enclosure_manager = main_node.get_node("Objects").get_node("EnclosureManager")
	for enclosure in enclosure_manager.get_existing_enclosures(cells):
		enclosure.call_deferred("calculate_enclosure_stats")

func get_enclosure_by_cell(cell):
	var main_node = get_tree().root.get_node("Main")
	var enclosure_manager = main_node.get_node("Objects").get_node("EnclosureManager")
	return enclosure_manager.get_enclosure_by_cell(cell)

func get_path_layer_cells():
	var main_node = get_tree().root.get_node("Main")
	var path_layer = main_node.get_node("TileMap").get_node('PathLayer') as TileMapLayer
	var path_cells = path_layer.get_used_cells()
	return path_cells

func set_navigation_rid(rid):
	navigation_rid = rid

func get_navigation_rid():
	return navigation_rid

func add_occupied_tiles(new_tiles):
	for tile in new_tiles:
		if tile not in occupied_tiles:
			new_occupied_tile.emit(tile)
			occupied_tiles.append(tile)
			
func remove_occupied_tiles(removed_tiles):
	for tile in removed_tiles:
		if tile in occupied_tiles:
			occupied_tiles.erase(tile)
