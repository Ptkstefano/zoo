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

var is_placing_water : bool = false
var water_starting_point : Vector2
var water_points : Array[Vector2]

var touch_debug : bool

var selected_res : Resource

@export var scenery_manager : SceneryManager
@export var animal_manager : AnimalManager

var start_tile_pos : Vector2i
var end_tile_pos : Vector2i

var is_bulldozing : bool = false
var is_camera_tool_selected : bool = false

var rotate_building : bool = false

enum TOOLS {NONE,PATH,ENCLOSURE,SHELTER,ANIMAL,SCENERY,TERRAIN,BUILDING,BULLDOZER,TREE,VEGETATION,FIXTURE,DECORATION,WATER}
var current_tool = TOOLS.NONE
var free_cam_tools = [TOOLS.NONE, TOOLS.BUILDING]
var scenery_tools = [TOOLS.TREE, TOOLS.VEGETATION, TOOLS.DECORATION, TOOLS.FIXTURE, TOOLS.WATER]
var building_placement_tools = [TOOLS.SHELTER, TOOLS.BUILDING]


signal zoom_camera
signal move_camera

signal building_placed
signal building_built

var fingers_touching = {}
var previous_touches_distance = 0

var zoom_started : bool = false


var cells : Array[Vector2i] = []
var dir

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
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
			
	if current_tool in free_cam_tools or is_camera_tool_selected:
		if !await handle_selection(event):
			handle_camera_input(event)
	if current_tool != TOOLS.NONE and !is_camera_tool_selected:
		handle_tooling_input(event)
	debug_keyboard_input(event)
	
func handle_camera_input(event):

	## Prevents screen to shoot around after zooming
	if fingers_touching.size() == 0:
		zoom_started = false
	
	## Handle touch camera movement
	if is_pressing:
		if event is InputEventScreenDrag:
			if fingers_touching.size() == 1 and !zoom_started:
				var touch_delta_t = touch_current_local_pos - touch_previous_local_pos
				touch_previous_local_pos = touch_current_local_pos
				move_camera.emit(touch_delta_t)
	
	## Handle camera zoom:
	if event is InputEventScreenDrag:
		if fingers_touching.size() > 1:
			zoom_started = true
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
			
func handle_tooling_input(event):
	if is_pressing:
		if !Helpers.is_valid_cell(touch_start_global_pos) or !Helpers.is_valid_cell(touch_current_global_pos):
			return
			
	if event is InputEventScreenDrag:
		if is_pressing:
			if !Helpers.is_valid_cell(touch_start_global_pos) or !Helpers.is_valid_cell(touch_current_global_pos):
				return
			if current_tool == TOOLS.PATH:
				highlight_path()
			if current_tool == TOOLS.ENCLOSURE:
				highlight_area()
			if current_tool == TOOLS.TERRAIN:
				highlight_area()
			if current_tool in scenery_tools:
				if is_bulldozing:
					if current_tool == TOOLS.WATER:
						is_placing_water = false
						bulldoze_water()
					else:
						bulldoze()
					
			if current_tool == TOOLS.WATER:
				if is_placing_water:
					if touch_current_global_pos.distance_to(water_points[water_points.size()-1]) > 20:
						water_points.append(touch_current_global_pos)
						$"../Objects/WaterManager".draw_placeholder(water_points)
					#print(touch_current_global_pos.distance_to(water_points[water_points.size()-1]))
					
					

	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_pressing = true
			if current_tool == TOOLS.WATER:
				is_placing_water = true
				water_starting_point = touch_start_global_pos
				water_points.append(water_starting_point)
		if event.is_released():
			if current_tool in building_placement_tools:
				building_placed.emit()
				highlight_building_area()
			else:
				$"../TileMap/HighlightLayer".clear_highlight()
			is_pressing = false
			if current_tool == TOOLS.PATH:
				if is_bulldozing:
					$"../PathManager".remove_path(cells)
					return
				if $"../EnclosureManager".get_enclosure_overlap(cells):
					return
				$"../PathManager".build_path(cells, selected_res)
			if current_tool == TOOLS.ENCLOSURE:
				if is_bulldozing:
					$"../EnclosureManager".remove_enclosure(cells)
					return
				if $"../PathManager".get_path_overlap(cells):
					return
				$"../EnclosureManager".build_enclosure(cells, selected_res)
			if current_tool == TOOLS.TERRAIN:
				$"../TerrainManager".build_terrain(cells, selected_res)
			if current_tool == TOOLS.ANIMAL:
				animal_manager.spawn_animal(touch_start_global_pos, selected_res)
			if current_tool == TOOLS.TREE:
				if !is_bulldozing:
					scenery_manager.place_tree(touch_start_global_pos, selected_res)
			if current_tool == TOOLS.VEGETATION:
				if !is_bulldozing:
					scenery_manager.place_vegetation(touch_start_global_pos, selected_res)
			if current_tool == TOOLS.FIXTURE:
				if !is_bulldozing:
					$"../Objects/FixtureManager".place_fixture(touch_start_global_pos, selected_res)
			if current_tool == TOOLS.DECORATION:
				if !is_bulldozing:
					scenery_manager.place_decoration(touch_start_global_pos, selected_res)
			if current_tool == TOOLS.WATER:
				if !is_bulldozing:
					is_placing_water = false
					$"../Objects/WaterManager".create_water_body(water_points)
					$"../Objects/WaterManager".clear_placeholder()
					water_points = []
				else:
					$"../Objects/WaterManager".clear_placeholder()
					water_points = []


func handle_selection(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			if current_tool == TOOLS.NONE:
				$DetectableCollider.global_position = touch_start_global_pos
				#var overlapping_areas = $DetectableCollider.get_overlapping_areas()
				#if overlapping_areas.size() > 0:
					#overlapping_areas[0].clicked()
					#return true
		else:
			## Done to ensure double clicking on a building doesn't fail
			$DetectableCollider.global_position = Vector2(9999,9999)
	return false

func debug_keyboard_input(event):
	if event is InputEventKey:
		if event.keycode == 49 and event.is_pressed():
			if $"../UI".visible:
				$"../UI".visible = false
			else:
				$"../UI".visible = true
		if event.keycode == 50 and event.is_pressed():
			if !$"../UI/MarginContainer/Top-Right/VBoxContainer/DebugScreen".visible:
				$"../UI/MarginContainer/Top-Right/VBoxContainer/DebugScreen".visible = true
				$"../TileMap/GridLayer".visible = true
			else:
				$"../UI/MarginContainer/Top-Right/VBoxContainer/DebugScreen".visible = false
				$"../TileMap/GridLayer".visible = false
		if event.keycode == 4194326:
			if event.is_pressed():
				is_bulldozing = true
			elif event.is_released():
				is_bulldozing = false
				
		if event.keycode == 4194325:
			if event.is_pressed():
				is_camera_tool_selected = true
			elif event.is_released():
				is_camera_tool_selected = false

func highlight_path():
	var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
	var tilepos = tile_map_layer.local_to_map(touch_current_global_pos)
	start_tile_pos = tile_map_layer.local_to_map(touch_start_global_pos)
	end_tile_pos = tilepos
	var x_press_diff = touch_current_global_pos.x - touch_start_global_pos.x
	var y_press_diff = touch_current_global_pos.y - touch_start_global_pos.y
	var x_tile_diff = end_tile_pos.x - start_tile_pos.x
	var y_tile_diff = end_tile_pos.y - start_tile_pos.y
	cells.clear()
	if abs(x_tile_diff) > abs(y_tile_diff):
		dir = 'x'
		for x in range(abs(x_tile_diff) + 1):
			if start_tile_pos.x < end_tile_pos.x:
				var new_coordinate = Vector2i(start_tile_pos.x + x, start_tile_pos.y)
				cells.append(new_coordinate)
			else:
				var new_coordinate = Vector2i(start_tile_pos.x - x, start_tile_pos.y)
				cells.append(new_coordinate)
	else:
		dir = 'y'
		for y in range(abs(y_tile_diff) + 1):
			if start_tile_pos.y < end_tile_pos.y:
				var new_coordinate = Vector2i(start_tile_pos.x, start_tile_pos.y + y)
				cells.append(new_coordinate)
			else:
				var new_coordinate = Vector2i(start_tile_pos.x, start_tile_pos.y - y)
				cells.append(new_coordinate)
	$"../TileMap/HighlightLayer".apply_highlight(cells, is_bulldozing)
	
func highlight_area():
	var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
	var tilepos = tile_map_layer.local_to_map(touch_current_global_pos)
	start_tile_pos = tile_map_layer.local_to_map(touch_start_global_pos)
	end_tile_pos = tilepos
	var x_tile_diff = end_tile_pos.x - start_tile_pos.x
	var y_tile_diff = end_tile_pos.y - start_tile_pos.y
	cells.clear()
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
			cells.append(new_coordinate)
	$"../TileMap/HighlightLayer".apply_highlight(cells, is_bulldozing)

func highlight_building_area():
	var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
	#if selected_res is not building_resource:
		#return
	start_tile_pos = tile_map_layer.local_to_map(touch_start_global_pos)
	cells.clear()
	if !rotate_building:
		for x in range(abs(selected_res.size.x)):
			for y in range(abs(selected_res.size.y)):
				var new_coordinate = Vector2i(start_tile_pos.x - x, start_tile_pos.y - y)
				cells.append(new_coordinate)
	if rotate_building:
		for x in range(abs(selected_res.size.x)):
			for y in range(abs(selected_res.size.y)):
				var new_coordinate = Vector2i(start_tile_pos.x - y, start_tile_pos.y - x)
				cells.append(new_coordinate)
	if current_tool == TOOLS.BUILDING:
		if $"../EnclosureManager".get_enclosure_overlap(cells):
			$"../TileMap/HighlightLayer".clear_highlight()
			return
	if current_tool == TOOLS.SHELTER:
		if !$"../EnclosureManager".get_enclosure_overlap(cells):
			$"../TileMap/HighlightLayer".clear_highlight()
			return
	$"../TileMap/HighlightLayer".apply_highlight(cells, false)

func rotate_building_toggle():
	if rotate_building:
		rotate_building = false
	else:
		rotate_building = true
	highlight_building_area()

# called from UI node
func build_building():
	$"../TileMap/HighlightLayer".clear_highlight()
	building_built.emit()
	$"../Objects/BuildingManager".build_building(selected_res, start_tile_pos, rotate_building, cells)

func build_shelter():
	$"../TileMap/HighlightLayer".clear_highlight()
	building_built.emit()
	$"../Objects/ShelterManager".build_shelter(selected_res, start_tile_pos, rotate_building, cells)
	
func bulldoze():
	$BulldozerCollider.global_position = touch_current_global_pos
	await get_tree().create_timer(0.25).timeout
	$BulldozerCollider.global_position = Vector2(9999,9999)

func bulldoze_water():
	$BulldozerWaterCollider.global_position = touch_current_global_pos
	await get_tree().create_timer(0.25).timeout
	$BulldozerWaterCollider.global_position = Vector2(9999,9999)
