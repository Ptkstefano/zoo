extends Node2D

class_name InputController

var is_pressing : bool = false

var press_start_pos : Vector2

var start_tile_pos : Vector2i
var end_tile_pos : Vector2i

enum TOOLS {NONE,PATH,AREA}
var current_tool = TOOLS.NONE

var coords = []
var dir

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## Code for highlighting in a straight line
	if is_pressing:
		if current_tool == TOOLS.PATH:
			highlight_path()
		if current_tool == TOOLS.AREA:
			highlight_area()

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				press_start_pos = get_global_mouse_position()
				is_pressing = true
			if event.is_released():
				$"../TileMap/HighlightLayer".clear_highlight()
				is_pressing = false
				if current_tool == TOOLS.PATH:
					$"../PathManager".build_path(coords, dir)
				if current_tool == TOOLS.AREA:
					$"../AreaManager".build_area(coords)

		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				press_start_pos = get_global_mouse_position()
				is_pressing = true
			if event.is_released():
				$"../TileMap/HighlightLayer".clear_highlight()
				is_pressing = false
				if current_tool == TOOLS.PATH:
					$"../PathManager".remove_path(coords)
				if current_tool == TOOLS.AREA:
					$"../AreaManager".remove_area(coords)
				


func highlight_path():
	var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
	var tilepos = tile_map_layer.local_to_map(get_global_mouse_position())
	start_tile_pos = tile_map_layer.local_to_map(press_start_pos)
	end_tile_pos = tilepos
	var x_press_diff = get_global_mouse_position().x - press_start_pos.x
	var y_press_diff = get_global_mouse_position().y - press_start_pos.y
	var x_tile_diff = end_tile_pos.x - start_tile_pos.x
	var y_tile_diff = end_tile_pos.y - start_tile_pos.y
	coords.clear()
	if abs(x_tile_diff) > abs(y_tile_diff):
		dir = 'x'
		for x in range(abs(x_tile_diff) + 1):
			if start_tile_pos.x < end_tile_pos.x:
				var new_coordinate = Vector2i(start_tile_pos.x + x, start_tile_pos.y)
				coords.append(new_coordinate)
			else:
				var new_coordinate = Vector2i(start_tile_pos.x - x, start_tile_pos.y)
				coords.append(new_coordinate)
	else:
		dir = 'y'
		for y in range(abs(y_tile_diff) + 1):
			if start_tile_pos.y < end_tile_pos.y:
				var new_coordinate = Vector2i(start_tile_pos.x, start_tile_pos.y + y)
				coords.append(new_coordinate)
			else:
				var new_coordinate = Vector2i(start_tile_pos.x, start_tile_pos.y - y)
				coords.append(new_coordinate)
	$"../TileMap/HighlightLayer".apply_highlight(coords)
	
func highlight_area():
	var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
	var tilepos = tile_map_layer.local_to_map(get_global_mouse_position())
	start_tile_pos = tile_map_layer.local_to_map(press_start_pos)
	end_tile_pos = tilepos
	var x_tile_diff = end_tile_pos.x - start_tile_pos.x
	var y_tile_diff = end_tile_pos.y - start_tile_pos.y
	coords.clear()
	for x in range(abs(x_tile_diff)+1):
		for y in range(abs(y_tile_diff)+1):
			var new_coordinate = Vector2i.ZERO
			if end_tile_pos.x < start_tile_pos.x:
				new_coordinate.x = end_tile_pos.x + x
			else:
				new_coordinate.x = start_tile_pos.x + x
			if end_tile_pos.y < start_tile_pos.y:
				new_coordinate.y = end_tile_pos.y + y
			else:
				new_coordinate.y = start_tile_pos.y + y
			coords.append(new_coordinate)
	$"../TileMap/HighlightLayer".apply_highlight(coords)
