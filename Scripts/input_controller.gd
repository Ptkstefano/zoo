extends Node2D

class_name InputController

var is_pressing : bool = false
var is_pressing_middle = false

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

var free_camera_mode : bool = false

var building_direction : IdRefs.DIRECTIONS = IdRefs.DIRECTIONS.E

#enum TOOLS {NONE,PATH,ENCLOSURE,SHELTER,ANIMAL,SCENERY,TERRAIN,BUILDING,TREE,VEGETATION,ROCK,FIXTURE,DECORATION,WATER,ENTRANCE,EATERY,RESTAURANT,SERVICE,ADMINISTRATION,BULLDOZER_ENCLOSURE,BULLDOZER_PATH,BULLDOZER_SCENERY,BULLDOZER_WATER}

var current_tool = IdRefs.TOOLS.NONE
var free_cam_tools = [IdRefs.TOOLS.NONE]
var bulldozer_tools = [IdRefs.TOOLS.BULLDOZER_ENCLOSURE, IdRefs.TOOLS.BULLDOZER_FIXTURE, IdRefs.TOOLS.BULLDOZER_PATH, IdRefs.TOOLS.BULLDOZER_SCENERY, IdRefs.TOOLS.BULLDOZER_WATER]
var hide_ui_tools = [IdRefs.TOOLS.ENCLOSURE, IdRefs.TOOLS.PATH, IdRefs.TOOLS.TERRAIN]
var scenery_tools = [IdRefs.TOOLS.TREE, IdRefs.TOOLS.VEGETATION, IdRefs.TOOLS.FIXTURE, IdRefs.TOOLS.WATER, IdRefs.TOOLS.ROCK]
var building_placement_tools = [IdRefs.TOOLS.BUILDING, IdRefs.TOOLS.SHELTER, IdRefs.TOOLS.EATERY, IdRefs.TOOLS.RESTAURANT, IdRefs.TOOLS.SERVICE, IdRefs.TOOLS.ADMINISTRATION, IdRefs.TOOLS.DECORATION]


signal zoom_camera
signal move_camera
signal move_camera_in_direction

var fingers_touching = {}
var previous_touches_distance = 0

var zoom_started : bool = false

var cells : Array[Vector2i] = []
var dir

var y_camera_threshhold
var x_camera_threshhold

signal ui_visibility

func _ready() -> void:
	y_camera_threshhold = get_viewport().get_visible_rect().size.y * 0.1
	x_camera_threshhold = get_viewport().get_visible_rect().size.x * 0.1
	SignalBus.tool_selected.connect(apply_tool)
	SignalBus.tool_deselected.connect(deselect_tool)
	SignalBus.free_camera.connect(on_free_camera_toggled)
	SignalBus.rotate_building.connect(rotate_building_toggle)
	SignalBus.building_built.connect(build_building)
	

func apply_tool(tool, resource):
	## If animal, resource is stored_animal class instead
	if resource:
		selected_res = resource
	current_tool = tool
	set_bulldozer_filters(tool)

func deselect_tool():
	selected_res = null
	current_tool = IdRefs.TOOLS.NONE
	free_camera_mode = false
	clear_highlight()
	
func on_free_camera_toggled(value):
	free_camera_mode = value

func _physics_process(delta: float) -> void:
	if is_pressing:
		if current_tool in [IdRefs.TOOLS.PATH, IdRefs.TOOLS.ENCLOSURE, IdRefs.TOOLS.TERRAIN]:
			border_camera_movement()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_pressing = true
			touch_start_global_pos = get_canvas_transform().affine_inverse().translated(event.position/$"../Camera2D".zoom).origin ## This code translates the position of the touch to global
			touch_current_global_pos = get_canvas_transform().affine_inverse().translated(event.position/$"../Camera2D".zoom).origin
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
			
	if current_tool in free_cam_tools or free_camera_mode:
		if !await handle_selection(event):
			handle_camera_input(event)
	if current_tool in bulldozer_tools and !free_camera_mode:
		handle_bulldozing_input(event)
	else:
		$BulldozerCollider.global_position = Vector2(9999,9999)
	if current_tool != IdRefs.TOOLS.NONE and !free_camera_mode and current_tool not in bulldozer_tools:
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
		if !Helpers.is_valid_position(touch_start_global_pos) or !Helpers.is_valid_position(touch_current_global_pos):
			return
			
	if event is InputEventScreenDrag:
		if is_pressing:
			if current_tool in hide_ui_tools:
				SignalBus.ui_visibility.emit(false)
			if !Helpers.is_valid_position(touch_start_global_pos) or !Helpers.is_valid_position(touch_current_global_pos):
				return
			if current_tool == IdRefs.TOOLS.PATH:
				highlight_area()
			if current_tool == IdRefs.TOOLS.ENCLOSURE:
				highlight_area()
			if current_tool == IdRefs.TOOLS.TERRAIN:
				highlight_area()
			if current_tool == IdRefs.TOOLS.VEGETATION:
				if touch_current_global_pos.distance_to(previous_snapshot_pos) > 100:
					previous_snapshot_pos = touch_current_global_pos
					if vegetation_brush:
						for i in 5:
							## TODO - Allow player to customize min distance and offset
							var random_offset = Vector2(randf_range(-25,25), randf_range(-25,25))
							var random_position = touch_current_global_pos + random_offset
							if Helpers.is_valid_position(random_position):
								scenery_manager.place_vegetation(random_position, selected_res, null, null)
					else:
						scenery_manager.place_vegetation(touch_current_global_pos, selected_res, null, null)
					
			if current_tool == IdRefs.TOOLS.WATER:
				if is_placing_water:
					if touch_current_global_pos.distance_to(water_points[water_points.size()-1]) > 20:
						water_points.append(touch_current_global_pos)
						$"../Objects/WaterManager".draw_placeholder(water_points)

	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_pressing = true
			if current_tool == IdRefs.TOOLS.WATER:
				is_placing_water = true
				water_starting_point = touch_start_global_pos
				water_points.append(water_starting_point)
		if event.is_released():
			SignalBus.ui_visibility.emit(true)
			if current_tool in building_placement_tools:
				SignalBus.building_placed.emit()
				highlight_building_area()
			else:
				$"../TileMap/HighlightLayer".clear_highlight()
			is_pressing = false
			if current_tool == IdRefs.TOOLS.PATH:
				if $"../Objects/EnclosureManager".get_enclosure_overlap(cells):
					return
				$"../PathManager".build_path(cells.duplicate(), selected_res.atlas_y)
				cells.clear()
			if current_tool == IdRefs.TOOLS.ENCLOSURE:
				if $"../PathManager".get_path_overlap(cells):
					return
				if cells.is_empty():
					return
				$"../Objects/EnclosureManager".build_enclosure(null, cells.duplicate(), null, selected_res, false)
				cells.clear()
			if current_tool == IdRefs.TOOLS.TERRAIN:
				$"../TerrainManager".build_terrain(cells.duplicate(), selected_res.atlas.y)
				cells.clear()
			if current_tool == IdRefs.TOOLS.ANIMAL:
				##selected_res is, in this case, an StoredAnimal
				animal_manager.spawn_stored_animal(touch_start_global_pos, selected_res)
			if current_tool == IdRefs.TOOLS.TREE:
				scenery_manager.place_tree(touch_start_global_pos, selected_res, null, null)
			if current_tool == IdRefs.TOOLS.VEGETATION:
				if vegetation_brush:
					previous_snapshot_pos = Vector2(9999,9999)
					return
				scenery_manager.place_vegetation(touch_start_global_pos, selected_res, null, null)
			if current_tool == IdRefs.TOOLS.FIXTURE:
				$"../Objects/FixtureManager".place_fixture(touch_start_global_pos, selected_res, free_placing_fixture, null)
			if current_tool == IdRefs.TOOLS.ROCK:
				scenery_manager.place_rock(touch_start_global_pos, selected_res, null)
			if current_tool == IdRefs.TOOLS.WATER:
				is_placing_water = false
				$"../Objects/WaterManager".create_water_body(water_points)
				$"../Objects/WaterManager".clear_placeholder()
				water_points = []
				#else:
					#$"../Objects/WaterManager".clear_placeholder()
					#water_points = []
			if current_tool == IdRefs.TOOLS.ENTRANCE:
				$"../Objects/EnclosureManager".place_entrance(touch_start_global_pos)
				

func handle_bulldozing_input(event):
	if event is InputEventScreenDrag:
		if is_pressing:
			if current_tool in hide_ui_tools:
				SignalBus.ui_visibility.emit(false)
			if !Helpers.is_valid_position(touch_start_global_pos) or !Helpers.is_valid_position(touch_current_global_pos):
				return
			if current_tool == IdRefs.TOOLS.BULLDOZER_PATH:
				highlight_area()
			if current_tool == IdRefs.TOOLS.BULLDOZER_ENCLOSURE:
				highlight_area()
			if current_tool in [IdRefs.TOOLS.BULLDOZER_SCENERY, IdRefs.TOOLS.BULLDOZER_WATER, IdRefs.TOOLS.BULLDOZER_FIXTURE]:
				$BulldozerCollider.global_position = touch_current_global_pos
			
			
	if event is InputEventScreenTouch:
		if event.is_pressed():
			is_pressing = true
		if event.is_released():
			SignalBus.ui_visibility.emit(true)
			$"../TileMap/HighlightLayer".clear_highlight()
			if current_tool == IdRefs.TOOLS.BULLDOZER_SCENERY:
				await get_tree().create_timer(1).timeout
				$BulldozerCollider.global_position = Vector2(9999,9999)
			if current_tool == IdRefs.TOOLS.BULLDOZER_WATER:
				await get_tree().create_timer(1).timeout
				$BulldozerCollider.global_position = Vector2(9999,9999)
			if current_tool == IdRefs.TOOLS.BULLDOZER_PATH:
				$"../PathManager".remove_path(cells.duplicate())
				cells.clear()
			if current_tool == IdRefs.TOOLS.BULLDOZER_ENCLOSURE:
				$"../Objects/EnclosureManager".remove_enclosure_cells(cells.duplicate())
				cells.clear()


func handle_selection(event):
	if event is InputEventScreenTouch:
		if event.is_released():
			if current_tool == IdRefs.TOOLS.NONE:
				if !is_screen_drag():
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
			if $"../UI_V".visible:
				$"../UI_V".visible = false
			else:
				$"../UI_V".visible = true
		if event.keycode == 50 and event.is_pressed():
			if !%DebugScreen.visible:
				%DebugScreen.visible = true
				$"../TileMap/GridLayer".visible = true
			else:
				%DebugScreen.visible = false
				$"../TileMap/GridLayer".visible = false
				
		if event.keycode == 4194325:
			if event.is_pressed():
				free_camera_mode = true
			elif event.is_released():
				free_camera_mode = false
				
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
	elif current_tool == IdRefs.TOOLS.ENCLOSURE:
		if $"../Objects/EnclosureManager".get_existing_enclosures_in_area(cells).size() == 0:
			$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.YELLOW)
		elif $"../Objects/EnclosureManager".get_existing_enclosures_in_area(cells).size() == 1:
			var new_and_existing_cells = $"../Objects/EnclosureManager".get_existing_enclosures_in_area(cells).front().enclosure_cells + cells
			$"../TileMap/HighlightLayer".apply_highlight(new_and_existing_cells, IdRefs.HIGHLIGHT_TYPES.BLUE)
		elif $"../Objects/EnclosureManager".get_existing_enclosures_in_area(cells).size() > 1:
			$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.RED)

	else:
		$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.YELLOW)

func clear_highlight():
	$"../TileMap/HighlightLayer".clear_highlight()

func highlight_building_area():
	var tile_map_layer = $"../TileMap/TerrainLayer" as TileMapLayer
	#if selected_res is not building_resource:
		#return
	start_tile_pos = tile_map_layer.local_to_map(touch_start_global_pos)
	cells.clear()
	cells = Helpers.get_building_cells(selected_res.size, start_tile_pos, building_direction).duplicate()
	if current_tool in building_placement_tools:
		if current_tool == IdRefs.TOOLS.SHELTER:
			for cell in cells:
				if !$"../Objects/EnclosureManager".get_enclosure_overlap([cell]):
					$"../TileMap/HighlightLayer".clear_highlight()
					return
		else:
			if $"../Objects/EnclosureManager".get_enclosure_overlap(cells):
				$"../TileMap/HighlightLayer".clear_highlight()
				return

	if building_direction == IdRefs.DIRECTIONS.E:
		$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.BUILDING_E)
	elif building_direction == IdRefs.DIRECTIONS.S:
		$"../TileMap/HighlightLayer".apply_highlight(cells, IdRefs.HIGHLIGHT_TYPES.BUILDING_S)
		

func rotate_building_toggle():
	building_direction = selected_res.possible_directions.find(building_direction) + 1
	if building_direction >= selected_res.possible_directions.size():
		building_direction = selected_res.possible_directions[0]
	highlight_building_area()

# called from UI node
func build_building():
	$"../TileMap/HighlightLayer".clear_highlight()
	#SignalBus.building_placed.emit()
	if selected_res is building_resource:
		$"../Objects/BuildingManager".build_building(selected_res, start_tile_pos, building_direction, null)
	elif selected_res is shelter_resource:
		$"../Objects/ShelterManager".build_shelter(selected_res, start_tile_pos, building_direction)
	elif selected_res is decoration_resource:
		scenery_manager.place_decoration(touch_start_global_pos, selected_res, building_direction, null)

func bulldoze_water():
	$BulldozerWaterCollider.global_position = touch_current_global_pos
	await get_tree().create_timer(1).timeout
	$BulldozerWaterCollider.global_position = Vector2(9999,9999)
			
func set_bulldozer_filters(tool):
	for collision_layer in [12, 17, 18, 19, 20, 21]:
		$BulldozerCollider.set_collision_layer_value(collision_layer, false)
	if tool == IdRefs.TOOLS.BULLDOZER_WATER:
		$BulldozerCollider.set_collision_layer_value(12, true) ## Water
	if tool == IdRefs.TOOLS.BULLDOZER_SCENERY:
		for collision_layer in [17, 18, 21]:
			$BulldozerCollider.set_collision_layer_value(collision_layer, true) 
	if tool == IdRefs.TOOLS.BULLDOZER_FIXTURE:
		for collision_layer in [19, 20]:
			$BulldozerCollider.set_collision_layer_value(collision_layer, true)

func border_camera_movement():
	var screen_size = get_viewport().get_visible_rect().size
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

func is_screen_drag():
	## Defines how far the player can drag the screen and still detect clickable elements
	if touch_start_global_pos.distance_to(touch_current_global_pos) > 10:
		return true
	else:
		return false
