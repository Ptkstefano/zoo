extends Node2D

class_name InputController

var is_pressing : bool = false
var is_pressing_middle = false

var press_start_pos : Vector2
var press_current_pos : Vector2

var press_middle_pos

var selected_res : Resource

@export var scenery_manager : SceneryManager
@export var animal_manager : AnimalManager

var start_tile_pos : Vector2i
var end_tile_pos : Vector2i

enum TOOLS {NONE,PATH,AREA,ANIMAL,SCENERY,TERRAIN,BULLDOZER}
var current_tool = TOOLS.NONE

signal zoom_camera
signal move_camera

var coords = []
var dir

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if is_pressing:
		press_current_pos = get_global_mouse_position()
		if !Helpers.is_valid_cell(press_start_pos) or !Helpers.is_valid_cell(press_current_pos):
			return
		if current_tool == TOOLS.PATH:
			highlight_path()
		if current_tool == TOOLS.AREA:
			highlight_area()
		if current_tool == TOOLS.TERRAIN:
			highlight_area()
		if current_tool == TOOLS.BULLDOZER:
			$BulldozerCollider.global_position = press_current_pos
			for object in $BulldozerCollider.get_overlapping_bodies():
				object.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				press_start_pos = get_global_mouse_position()
				is_pressing = true
			if event.is_released():
				$"../TileMap/HighlightLayer".clear_highlight()
				is_pressing = false
				if current_tool == TOOLS.PATH:
					if $"../AreaManager".get_area_overlap(coords):
						return
					$"../PathManager".build_path(coords, dir, selected_res)
				if current_tool == TOOLS.AREA:
					if $"../PathManager".get_fence_overlap(coords):
						return
					$"../AreaManager".build_area(coords, selected_res)
				if current_tool == TOOLS.TERRAIN:
					$"../TerrainManager".build_terrain(coords, selected_res)
				if current_tool == TOOLS.ANIMAL:
					animal_manager.spawn_animal(press_start_pos, selected_res)
				if current_tool == TOOLS.SCENERY:
					scenery_manager.plop(press_start_pos)

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
	if event is InputEventKey:
		if event.keycode == 49 and event.is_pressed():
			if $"../UI".visible:
				$"../UI".visible = false
			else:
				$"../UI".visible = true
		if event.keycode == 50 and event.is_pressed():
			if !$"../UI/DebugScreen".visible:
				$"../UI/DebugScreen".visible = true
				$"../TileMap/GridLayer".visible = true
			else:
				$"../UI/DebugScreen".visible = false
				$"../TileMap/GridLayer".visible = false
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.is_pressed():
				is_pressing_middle = true
				press_middle_pos = event.position
			else:
				is_pressing_middle = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera.emit(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera.emit(-1)
	elif event is InputEventMouseMotion and is_pressing_middle:
		var mouse_delta = event.position - press_middle_pos
		press_middle_pos = event.position
		move_camera.emit(mouse_delta)
		

func highlight_path():
	var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
	var tilepos = tile_map_layer.local_to_map(press_current_pos)
	start_tile_pos = tile_map_layer.local_to_map(press_start_pos)
	end_tile_pos = tilepos
	var x_press_diff = press_current_pos.x - press_start_pos.x
	var y_press_diff = press_current_pos.y - press_start_pos.y
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
	var tilepos = tile_map_layer.local_to_map(press_current_pos)
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
