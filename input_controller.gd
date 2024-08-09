extends Node2D

var is_pressing : bool = false

var start_tile_pos : Vector2
var end_tile_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_pressing:
		var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
		var tilepos = tile_map_layer.local_to_map(get_global_mouse_position())
		end_tile_pos = tilepos
		var x_diff = end_tile_pos.x - start_tile_pos.x
		var y_diff = end_tile_pos.y - start_tile_pos.y
		var coords = []
		for x in range(abs(x_diff)):
			for y in range(abs(y_diff)):
				var new_coordinate = Vector2.ZERO
				if end_tile_pos.x < start_tile_pos.x:
					new_coordinate.x = end_tile_pos.x + x
				else:
					new_coordinate.x = start_tile_pos.x + x + 1
				if end_tile_pos.y < start_tile_pos.y:
					new_coordinate.y = end_tile_pos.y + y
				else:
					new_coordinate.y = start_tile_pos.y + y + 1
				coords.append(new_coordinate)
		$"../TileMap/HighlightLayer".apply_highlight(coords)
		
		#for x in range(start_tile_pos.x, end_tile_pos.x + 1):
			#for y in range(start_tile_pos.y, end_tile_pos.y + 1):
				#var current_pos = Vector2(x, y)
				#print(current_pos)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
				var tilepos = tile_map_layer.local_to_map(get_global_mouse_position())
				is_pressing = true
				start_tile_pos = tilepos
			if event.is_released():
				var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
				is_pressing = false
				#for x in range(start_tile_pos.x, end_tile_pos.x + 1):
					#for y in range(start_tile_pos.y, end_tile_pos.y + 1):
						#var current_pos = Vector2(x, y)
						#tile_map_layer.set_cell(current_pos, 0, Vector2(1,0))
				
func get_tile_via_tilemap():
	# Tried making this work for ages for no result
	var tile_map_layer = $"../TileMap/FenceLayer"
	var tilepos = tile_map_layer.local_to_map(get_global_mouse_position())
	var source_id = tile_map_layer.get_cell_source_id(tilepos)
	tile_map_layer.get_cell()
	if source_id > -1:
		var scene_source = tile_map_layer.tile_set.get_source(source_id)
		if scene_source is TileSetScenesCollectionSource:
			#print(scene_source.get_scene_tiles_count())
			var alt_id = tile_map_layer.get_cell_alternative_tile(tilepos)
			#print(alt_id)
			var scene = scene_source.get_scene_tile_scene(alt_id)
			#print(scene)

#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#if event.is_pressed():
				#$MouseDetector.global_position = get_global_mouse_position()
				#if $MouseDetector.get_overlapping_areas():
					#await get_tree().create_timer(0.1).timeout
					#for area in $MouseDetector.get_overlapping_areas():
						#print(area.get_parent())
						#area.get_parent().change_terrain(1)
