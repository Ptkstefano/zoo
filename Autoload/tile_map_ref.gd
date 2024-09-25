extends TileMapLayer


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

func update_enclosures(cells):
	var main_node = get_tree().root.get_node("Main")
	var enclosure_manager = main_node.get_node("EnclosureManager")
	for enclosure in enclosure_manager.get_existing_enclosures(cells):
		enclosure.call_deferred("calculate_enclosure_stats")

func get_enclosure_by_cell(cell):
	var main_node = get_tree().root.get_node("Main")
	var enclosure_manager = main_node.get_node("EnclosureManager")
	return enclosure_manager.get_enclosure_by_cell(cell)
