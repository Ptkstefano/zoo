extends Node

var terrain_layer

func _ready() -> void:
	terrain_layer = get_parent().get_child(1).find_child('TileMap').find_child('TerrainLayer') as TileMapLayer
	print(terrain_layer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_adjacent(coordinate) -> Array:
	var e = Vector2i(coordinate.x + 1, coordinate.y)
	var s = Vector2i(coordinate.x, coordinate.y + 1)
	var w = Vector2i(coordinate.x - 1, coordinate.y)
	var n = Vector2i(coordinate.x, coordinate.y - 1)
	
	return [e, s, w, n]

func get_current_tile_z_index(position):
	var coordinate = terrain_layer.local_to_map(position)
	return (coordinate.x + coordinate.y)

func get_global_pos_of_cell(coordinate):
	return terrain_layer.map_to_local(coordinate)
