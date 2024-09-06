extends Node2D

class_name InputController

var is_pressing : bool = false
var is_pressing_middle = false

var press_start_gpos : Vector2
var press_current_gpos : Vector2

var press_start_lpos : Vector2
var press_current_lpos : Vector2
var previous_current_lpos : Vector2


var touch_start_global_pos : Vector2
var touch_current_global_pos : Vector2
var touch_previous_global_pos : Vector2

var touch_start_local_pos : Vector2
var touch_current_local_pos : Vector2
var touch_previous_local_pos : Vector2

var touch_debug : bool

var selected_res : Resource

@export var scenery_manager : SceneryManager
@export var animal_manager : AnimalManager

var start_tile_pos : Vector2i
var end_tile_pos : Vector2i

var is_bulldozing : bool = false

enum TOOLS {NONE,PATH,AREA,ANIMAL,SCENERY,TERRAIN,BULLDOZER}
var current_tool = TOOLS.NONE

signal zoom_camera
signal move_camera

var fingers_touching = {}
var previous_touches_distance = 0


var coords = []
var dir

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if is_pressing:
		if !Helpers.is_valid_cell(touch_start_global_pos) or !Helpers.is_valid_cell(touch_current_global_pos):
			return
		if current_tool == TOOLS.PATH:
			highlight_path()
		if current_tool == TOOLS.AREA:
			highlight_area()
		if current_tool == TOOLS.TERRAIN:
			highlight_area()

func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton:
		#return
		#if event.is_pressed():
			#is_pressing = true
			#press_start_gpos = get_global_mouse_position()
			#press_current_gpos = press_start_gpos
			##press_start_lpos = event.position
			##press_current_lpos = press_start_lpos
			##previous_current_lpos = press_start_lpos
		#elif event.is_released():
			#is_pressing = false
			#
	#if event is InputEventMouseMotion:
		#return
		#if is_pressing:
			#press_current_gpos = get_global_mouse_position()
			#press_current_lpos = event.position
			
	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_pressing = true
			touch_start_global_pos = get_canvas_transform().affine_inverse().translated(event.position/$"../Camera2D".zoom).origin ## This code translates the position of the touch to global
			touch_start_local_pos = event.position
			touch_current_local_pos = touch_start_local_pos
			touch_previous_local_pos = touch_start_local_pos
			## Get fingers on screen:
			fingers_touching[event.index] = event.position
		else:
			fingers_touching.erase(event.index)
			
	if event is InputEventScreenDrag:
		if is_pressing:
			fingers_touching[event.index] = event.position
			if event.index == fingers_touching.keys()[fingers_touching.keys().size() - 1]:
				touch_current_global_pos = get_canvas_transform().affine_inverse().translated(event.position/$"../Camera2D".zoom).origin
				touch_current_local_pos = event.position
			
		
	handle_tooling_input(event)
	handle_camera_input(event)
	debug_keyboard_input(event)
	
func handle_camera_input(event):

	## Handle touch camera movement
	if is_pressing:
		if event is InputEventScreenDrag:
				if current_tool == TOOLS.NONE and fingers_touching.size() == 1:
					var touch_delta_t = touch_current_local_pos - touch_previous_local_pos
					touch_previous_local_pos = touch_current_local_pos
					move_camera.emit(touch_delta_t)

	
	## Handle camera zoom:
	if event is InputEventScreenDrag:
		if fingers_touching.size() > 1:
			var touches_distance = fingers_touching.values()[0].distance_to(fingers_touching.values()[1])
			if touches_distance > previous_touches_distance:
				zoom_camera.emit(1)
			else:
				zoom_camera.emit(-1) 
			previous_touches_distance = touches_distance
	
	## Debug camera zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera.emit(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera.emit(-1)
			
	if event is InputEventKey:
		if event.keycode == 4194332 and event.is_pressed():
			var touch_event = InputEventScreenTouch.new()
			touch_event.position = Vector2(200, 300)  # Replace with the position where you want the touch
			touch_event.index = 3  # Touch index, 0 for the first finger
			touch_event.pressed = true
			Input.parse_input_event(touch_event)
			touch_debug = true

		elif event.keycode == 4194332 and touch_debug and event.is_released():
			# Simulate touch end
			var touch_event = InputEventScreenTouch.new()
			touch_event.position = Vector2(200, 300)  # Same position as above
			touch_event.index = 3
			touch_event.pressed = false
			Input.parse_input_event(touch_event)
			touch_debug = false
			

func handle_tooling_input(event):
	## Leaving this code here for now but if no issues then remove later
	#if event is InputEventScreenDrag:
		#return
		#if current_tool != TOOLS.NONE:
			#if is_pressing:
				#press_current_gpos = get_canvas_transform().affine_inverse().translated(event.position).origin
#
	#if event is InputEventScreenTouch:
		#return
		#if event.is_pressed():
			#press_start_gpos = get_canvas_transform().affine_inverse().translated(event.position).origin
			#is_pressing = true
		#if event.is_released():
			#$"../TileMap/HighlightLayer".clear_highlight()
			#is_pressing = false
			#if current_tool == TOOLS.PATH:
				#if is_bulldozing:
					#$"../PathManager".remove_path(coords)
					#return
				#if $"../AreaManager".get_area_overlap(coords):
					#return
				#$"../PathManager".build_path(coords, dir, selected_res)
			#if current_tool == TOOLS.AREA:
				#if is_bulldozing:
					#$"../AreaManager".remove_area(coords)
					#return
				#if $"../PathManager".get_fence_overlap(coords):
					#return
				#$"../AreaManager".build_area(coords, selected_res)
			#if current_tool == TOOLS.TERRAIN:
				#$"../TerrainManager".build_terrain(coords, selected_res)
			#if current_tool == TOOLS.ANIMAL:
				#animal_manager.spawn_animal(press_start_gpos, selected_res)
			#if current_tool == TOOLS.SCENERY:
				#if is_bulldozing:
					#for object in $BulldozerCollider.get_overlapping_bodies():
						#object.queue_free()
					#return
				#scenery_manager.plop(press_start_gpos)

	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_pressing = true
		if event.is_released():
			$"../TileMap/HighlightLayer".clear_highlight()
			is_pressing = false
			if current_tool == TOOLS.PATH:
				if is_bulldozing:
					$"../PathManager".remove_path(coords)
					return
				if $"../AreaManager".get_area_overlap(coords):
					return
				$"../PathManager".build_path(coords, dir, selected_res)
			if current_tool == TOOLS.AREA:
				if is_bulldozing:
					$"../AreaManager".remove_area(coords)
					return
				if $"../PathManager".get_fence_overlap(coords):
					return
				$"../AreaManager".build_area(coords, selected_res)
			if current_tool == TOOLS.TERRAIN:
				$"../TerrainManager".build_terrain(coords, selected_res)
			if current_tool == TOOLS.ANIMAL:
				animal_manager.spawn_animal(touch_start_global_pos, selected_res)
			if current_tool == TOOLS.SCENERY:
				if is_bulldozing:
					for object in $BulldozerCollider.get_overlapping_bodies():
						object.queue_free()
					return
				scenery_manager.plop(touch_start_global_pos)

func debug_keyboard_input(event):
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
		if event.keycode == 4194326:
			if event.is_pressed():
				is_bulldozing = true
			elif event.is_released():
				is_bulldozing = false

func highlight_path():
	var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
	var tilepos = tile_map_layer.local_to_map(touch_current_global_pos)
	start_tile_pos = tile_map_layer.local_to_map(touch_start_global_pos)
	end_tile_pos = tilepos
	var x_press_diff = touch_current_global_pos.x - touch_start_global_pos.x
	var y_press_diff = touch_current_global_pos.y - touch_start_global_pos.y
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
	var tilepos = tile_map_layer.local_to_map(touch_current_global_pos)
	start_tile_pos = tile_map_layer.local_to_map(touch_start_global_pos)
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
