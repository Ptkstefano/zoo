extends Node2D

class_name InputController

var is_pressing : bool = false
var is_pressing_middle = false

var press_start_gpos : Vector2
var press_current_gpos : Vector2

var press_start_lpos : Vector2
var press_current_lpos : Vector2
var previous_current_lpos : Vector2

var previous_snapshot_pos : Vector2

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

var vegetation_brush : bool = false
var free_placing_fixture : bool = false
var selected_animal_gender : int = 1

var is_camera_tool_selected : bool = false

var rotate_building : bool = false

enum TOOLS {NONE,PATH,ENCLOSURE,SHELTER,ANIMAL,SCENERY,TERRAIN,BUILDING,TREE,VEGETATION,ROCK,FIXTURE,DECORATION,WATER,ENTRANCE,EATERY,RESTAURANT,SERVICE,ADMINISTRATION,BULLDOZER_ENCLOSURE,BULLDOZER_PATH,BULLDOZER_SCENERY,BULLDOZER_WATER}

var current_tool = TOOLS.NONE:
	set(tool):
		apply_tool(tool)
		current_tool = tool
var free_cam_tools = [TOOLS.NONE, TOOLS.BUILDING]
var bulldozer_tools = [TOOLS.BULLDOZER_ENCLOSURE, TOOLS.BULLDOZER_PATH, TOOLS.BULLDOZER_SCENERY, TOOLS.BULLDOZER_WATER]
var hide_ui_tools = [TOOLS.ENCLOSURE, TOOLS.PATH, TOOLS.TERRAIN]
var scenery_tools = [TOOLS.TREE, TOOLS.VEGETATION, TOOLS.FIXTURE, TOOLS.WATER, TOOLS.ROCK]
var building_placement_tools = [TOOLS.SHELTER, TOOLS.EATERY, TOOLS.RESTAURANT, TOOLS.SERVICE, TOOLS.ADMINISTRATION, TOOLS.DECORATION]


signal zoom_camera
signal move_camera
signal move_camera_in_direction

signal building_placed
signal building_built

var fingers_touching = {}
var previous_touches_distance = 0

var zoom_started : bool = false

var cells : Array[Vector2i] = []
var dir

var screen_size : Vector2
var y_camera_threshhold
var x_camera_threshhold

signal ui_visibility

func _ready() -> void:
	screen_size = DisplayServer.window_get_size()
	y_camera_threshhold = screen_size.y * 0.1
	x_camera_threshhold = screen_size.x * 0.1

func _physics_process(delta: float) -> void:
	if is_pressing:
		if current_tool in [TOOLS.PATH, TOOLS.ENCLOSURE, TOOLS.TERRAIN]:
			border_camera_movement()

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
	if current_tool in bulldozer_tools and !is_camera_tool_selected:
		handle_bulldozing_input(event)
	else:
		$BulldozerCollider.global_position = Vector2(9999,9999)
	if current_tool != TOOLS.NONE and !is_camera_tool_selected and current_tool not in bulldozer_tools:
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
			if current_tool in hide_ui_tools:
				SignalBus.ui_visibility.emit(false)
			if !Helpers.is_valid_cell(touch_start_global_pos) or !Helpers.is_valid_cell(touch_current_global_pos):
				return
			if current_tool == TOOLS.PATH:
				highlight_area()
			if current_tool == TOOLS.ENCLOSURE:
				highlight_area()
			if current_tool == TOOLS.TERRAIN:
				highlight_area()
			if current_tool == TOOLS.VEGETATION:
				if vegetation_brush:
					if touch_current_global_pos.distance_to(previous_snapshot_pos) > 100:
						previous_snapshot_pos = touch_current_global_pos
						for i in 3:
							## TODO - Allow player to customize min distance and offset
							var random_offset = Vector2(randf_range(-50,50), randf_range(-50,50))
							scenery_manager.place_vegetation(touch_current_global_pos + random_offset, selected_res, null)
					
			if current_tool == TOOLS.WATER:
				if is_placing_water:
					if touch_current_global_pos.distance_to(water_points[water_points.size()-1]) > 20:
						water_points.append(touch_current_global_pos)
						$"../Objects/WaterManager".draw_placeholder(water_points)

	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_pressing = true
			if current_tool == TOOLS.WATER:
				is_placing_water = true
				water_starting_point = touch_start_global_pos
				water_points.append(water_starting_point)
		if event.is_released():
			SignalBus.ui_visibility.emit(true)
			if current_tool in building_placement_tools:
				building_placed.emit()
				highlight_building_area()
			else:
				$"../TileMap/HighlightLayer".clear_highlight()
			is_pressing = false
			if current_tool == TOOLS.PATH:
				if $"../Objects/EnclosureManager".get_enclosure_overlap(cells):
					return
				$"../PathManager".build_path(cells.duplicate(), selected_res.atlas_y)
				cells.clear()
			if current_tool == TOOLS.ENCLOSURE:
				if $"../PathManager".get_path_overlap(cells):
					return
				$"../Objects/EnclosureManager".build_enclosure(null, cells.duplicate(), null, selected_res)
				cells.clear()
			if current_tool == TOOLS.TERRAIN:
				$"../TerrainManager".build_terrain(cells.duplicate(), selected_res.atlas.y)
				cells.clear()
			if current_tool == TOOLS.ANIMAL:
				animal_manager.spawn_animal(touch_start_global_pos, selected_res, null, false, selected_animal_gender)
			if current_tool == TOOLS.TREE:
				scenery_manager.place_tree(touch_start_global_pos, selected_res, null)
			if current_tool == TOOLS.VEGETATION:
				if vegetation_brush:
					previous_snapshot_pos = touch_start_global_pos
					return
				scenery_manager.place_vegetation(touch_start_global_pos, selected_res, null)
			if current_tool == TOOLS.FIXTURE:
				$"../Objects/FixtureManager".place_fixture(touch_start_global_pos, selected_res, free_placing_fixture, null)
			if current_tool == TOOLS.ROCK:
				scenery_manager.place_rock(touch_start_global_pos, selected_res, null)
			if current_tool == TOOLS.WATER:
				is_placing_water = false
				$"../Objects/WaterManager".create_water_body(water_points)
				$"../Objects/WaterManager".clear_placeholder()
				water_points = []
				#else:
					#$"../Objects/WaterManager".clear_placeholder()
					#water_points = []
			if current_tool == TOOLS.ENTRANCE:
				$"../Objects/EnclosureManager".place_entrance(touch_start_global_pos)
				

func handle_bulldozing_input(event):
	if event is InputEventScreenDrag:
		if is_pressing:
			if current_tool in hide_ui_tools:
				SignalBus.ui_visibility.emit(false)
			if !Helpers.is_valid_cell(touch_start_global_pos) or !Helpers.is_valid_cell(touch_current_global_pos):
				return
			if current_tool == TOOLS.BULLDOZER_PATH:
				highlight_area()
			if current_tool == TOOLS.BULLDOZER_ENCLOSURE:
				highlight_area()
			if current_tool == TOOLS.BULLDOZER_SCENERY or current_tool == TOOLS.BULLDOZER_WATER:
				$BulldozerCollider.global_position = touch_current_global_pos
			
			
	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_pressing = true
		if event.is_released():
			SignalBus.ui_visibility.emit(true)
			$"../TileMap/HighlightLayer".clear_highlight()
			if current_tool == TOOLS.BULLDOZER_SCENERY:
				await get_tree().create_timer(1).timeout
				$BulldozerCollider.global_position = Vector2(9999,9999)
			if current_tool == TOOLS.BULLDOZER_WATER:
				await get_tree().create_timer(1).timeout
				$BulldozerCollider.global_position = Vector2(9999,9999)
			if current_tool == TOOLS.BULLDOZER_PATH:
				$"../PathManager".remove_path(cells.duplicate())
				cells.clear()
			if current_tool == TOOLS.BULLDOZER_ENCLOSURE:
				$"../Objects/EnclosureManager".remove_enclosure_cells(cells.duplicate())
				cells.clear()


func handle_selection(event):
	if event is InputEventScreenTouch:
		if event.is_released():
			if current_tool == TOOLS.NONE:
				$DetectableCollider.set_deferred('global_position', touch_start_global_pos)
				await get_tree().create_timer(0.1).timeout
				$DetectableCollider.set_deferred('global_position',Vector2(9999,9999))
				#var overlapping_areas = $DetectableCollider.call_deferred('get_overlapping_areas')
				#if overlapping_areas.size() > 0:
					#return true
		#else:
			## Done to ensure double clicking on a building doesn't fail
			#$DetectableCollider.global_position = Vector2(9999,9999)
	#return false

func debug_keyboard_input(event):
	if event is InputEventKey:
		if event.keycode == 49 and event.is_pressed():
			if $"../UI".visible:
				$"../UI".visible = false
			else:
				$"../UI".visible = true
		if event.keycode == 50 and event.is_pressed():
			if !%DebugScreen.visible:
				%DebugScreen.visible = true
				$"../TileMap/GridLayer".visible = true
			else:
				%DebugScreen.visible = false
				$"../TileMap/GridLayer".visible = false
				
		if event.keycode == 4194325:
			if event.is_pressed():
				is_camera_tool_selected = true
			elif event.is_released():
				is_camera_tool_selected = false
				
		if event.keycode == KEY_APOSTROPHE:
			if event.is_pressed():
				Engine.time_scale = 8
			elif event.is_released():
				Engine.time_scale = 1

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
	$"../TileMap/HighlightLayer".apply_highlight(cells, current_tool in bulldozer_tools)
	
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
	if current_tool in bulldozer_tools:
		$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.RED)
	elif current_tool == TOOLS.ENCLOSURE:
		if $"../Objects/EnclosureManager".get_existing_enclosures_in_area(cells).size() == 0:
			$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.YELLOW)
		elif $"../Objects/EnclosureManager".get_existing_enclosures_in_area(cells).size() == 1:
			var new_and_existing_cells = $"../Objects/EnclosureManager".get_existing_enclosures_in_area(cells).front().enclosure_cells + cells
			$"../TileMap/HighlightLayer".apply_highlight(new_and_existing_cells, IdRefs.HIGHLIGHT_TYPES.BLUE)
		elif $"../Objects/EnclosureManager".get_existing_enclosures_in_area(cells).size() > 1:
			$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.RED)

	else:
		$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.YELLOW)

func highlight_building_area():
	var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
	#if selected_res is not building_resource:
		#return
	start_tile_pos = tile_map_layer.local_to_map(touch_start_global_pos)
	cells.clear()
	cells = Helpers.get_building_cells(selected_res.size, start_tile_pos, rotate_building).duplicate()
	if current_tool in building_placement_tools:
		if $"../Objects/EnclosureManager".get_enclosure_overlap(cells):
			$"../TileMap/HighlightLayer".clear_highlight()
			return
	#if current_tool == TOOLS.SHELTER:
		#if !$"../Objects/EnclosureManager".get_enclosure_overlap(cells):
			#$"../TileMap/HighlightLayer".clear_highlight()
			#return

	if !rotate_building:
		$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.BUILDING_S)
	else:
		$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.BUILDING_E)

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
	$"../Objects/BuildingManager".build_building(selected_res, start_tile_pos, rotate_building, null)

func build_shelter():
	$"../TileMap/HighlightLayer".clear_highlight()
	building_built.emit()
	
	## - TODO - Remove cells just like in build building()
	$"../Objects/ShelterManager".build_shelter(selected_res, start_tile_pos, rotate_building, cells)
	
func build_decoration():
	$"../TileMap/HighlightLayer".clear_highlight()
	building_built.emit()
	scenery_manager.place_decoration(touch_start_global_pos, selected_res, rotate_building, null)

func bulldoze_water():
	$BulldozerWaterCollider.global_position = touch_current_global_pos
	await get_tree().create_timer(1).timeout
	$BulldozerWaterCollider.global_position = Vector2(9999,9999)

func apply_tool(tool):
	if tool in bulldozer_tools:
		for collision_layer in [12, 17, 18, 19, 20, 21]:
			$BulldozerCollider.set_collision_layer_value(collision_layer, false)
		if tool == TOOLS.BULLDOZER_WATER:
			$BulldozerCollider.set_collision_layer_value(12, true) ## Water
			
func set_bulldozer_filters(filters):
	for key in filters:
		$BulldozerCollider.set_collision_layer_value(key, filters[key])

func border_camera_movement():
	var camera_direction = Vector2(0,0)
	if touch_current_local_pos.x < x_camera_threshhold:
		camera_direction.x = -1
	elif touch_current_local_pos.x > screen_size.x - x_camera_threshhold:
		camera_direction.x = 1
	if touch_current_local_pos.y < y_camera_threshhold:
		camera_direction.y = -1
	elif touch_current_local_pos.y > screen_size.y - y_camera_threshhold:
		camera_direction.y = 1
		
	move_camera_in_direction.emit(camera_direction)
