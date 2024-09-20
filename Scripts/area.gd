extends Node2D

class_name area

@onready var area_scene = preload("res://area.tscn")

var area_cells = []
var fence_cells = []

var area_animals = []

var current_fence

var area_central_point : Vector2

@onready var area_tilemap = $AreaTiles
@onready var fence_manager : FenceManager = $FenceManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fence_manager.area_tilemap = area_tilemap
	SignalBus.obstacle_changed.connect(update_navigation_region)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_animal_destination():
	var random_cell = area_cells.pick_random()
	var random_position = area_tilemap.map_to_local(random_cell)
	return random_position
	

func add_cells(coordinates, fence_res):
	if fence_res:
		current_fence = fence_res
	for coordinate in coordinates:
		area_tilemap.set_cell(coordinate, 0, Vector2i(0, 0))
		if !area_cells.has(coordinate):
			area_cells.append(coordinate)
	build_fence(current_fence)
	update_central_point()
	update_navigation_region()
			
func remove_cells(coordinates):
	for coordinate in coordinates:
		area_tilemap.set_cell(coordinate, -1, Vector2i(-1,-1))
		if area_cells.has(coordinate):
			area_cells.erase(coordinate)
			
	if area_cells.size() == 0:
		remove_area()
		return
	
	detect_continuity()
	build_fence(current_fence)
	redistribute_animals()
	update_central_point()
	update_navigation_region()
	
func detect_continuity():
	## Figures out if current area was broken into multiple areas and instantiates newly created areas as siblings
	if area_cells.size() == 0:
		return
	var iterated_coordinates = []
	var existing_areas = []
	var n_areas = 0
	
	while(iterated_coordinates.size() != area_cells.size()):
		var starting_cell = find_first_coordinate_not_matching(iterated_coordinates)
		n_areas += 1
		var current_area = []
		for coordinate in get_isolated_area(area_cells[starting_cell]):
			if !iterated_coordinates.has(coordinate):
				current_area.append(coordinate)
				iterated_coordinates.append(coordinate)
		existing_areas.append(current_area)
	
	if existing_areas.size() > 1:
		area_cells = existing_areas[0]
		for i in existing_areas.size():
			if i == 0:
				continue
			create_sibling_area(existing_areas[i])
		
func get_isolated_area(starting_coordinate):
	var current_iterated_coordinates = [starting_coordinate]
	for coordinate in current_iterated_coordinates:
		var adjacent_cells = Helpers.get_adjacent(coordinate)
		for adjacent_cell in adjacent_cells:
			if area_cells.has(adjacent_cell):
				if !current_iterated_coordinates.has(adjacent_cell):
					current_iterated_coordinates.append(adjacent_cell)
	return current_iterated_coordinates
					
		
func find_first_coordinate_not_matching(iterated_coordinates):
	for coordinate in area_cells:
		if coordinate not in iterated_coordinates:
			return area_cells.find(coordinate)
			
func create_sibling_area(cells):
	var sibling = area_scene.instantiate()
	add_sibling(sibling)
	remove_cells(cells)
	sibling.add_cells(cells, current_fence)
	
func build_fence(fence_res):
	## Actually instantiates the visual nodes of the fence
	remove_fence()
	fence_manager.build_fence(area_cells, fence_res)

func remove_fence():
	fence_manager.remove_fence()

func add_animal(animal):
	area_animals.append(animal)

func redistribute_animals():
	for animal in area_animals:
		animal.global_position = area_tilemap.map_to_local(area_cells.pick_random())

func remove_area():
	for animal in area_animals:
		animal.remove_animal()
		
	queue_free()

func update_central_point():
	var cells = $FenceManager.fence_cells
	var sum_x: float = 0.0
	var sum_y: float = 0.0
	var num_cells: int = cells.size()

	for cell in cells:
		sum_x += cell.x
		sum_y += cell.y

	var centroid_x: float = sum_x / num_cells
	var centroid_y: float = sum_y / num_cells
	
	var central_point = Vector2(centroid_x, centroid_y)

	area_central_point = Helpers.get_global_pos_of_cell(central_point)
	
func update_navigation_region():
	$LandRegion.bake_navigation_polygon()
	$WaterRegion.bake_navigation_polygon()
	
	#var new_navigation_mesh = NavigationPolygon.new()
	#var coordinates = []
	#var ordered_cells = order_edge_cells($FenceManager.fence_cells)
	#print(ordered_cells)
	#for cell in ordered_cells:
		#var localpos = TileMapRef.map_to_local(cell)
		#if localpos not in coordinates:
			#coordinates.append(localpos)
	#new_navigation_mesh.clear_outlines()
	#new_navigation_mesh.add_outline(coordinates)
	##new_navigation_mesh.make_polygons_from_outline()
	#NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, NavigationMeshSourceGeometryData2D.new());
	#$NavigationRegion2D.navigation_polygon = new_navigation_mesh

func order_edge_cells(edge_cells: Array) -> Array:
	var ordered_cells = []
	var visited_cells = {}

	# Choose a starting cell
	var current_cell = edge_cells[0]
	ordered_cells.append(current_cell)
	visited_cells[current_cell] = true


	while len(ordered_cells) < len(edge_cells):
		var found_next = false
		
		# Check all neighbors of the current cell
		for neighbor in get_neighbors(current_cell):
			if neighbor in edge_cells and not visited_cells.has(neighbor):
				ordered_cells.append(neighbor)
				visited_cells[neighbor] = true
				current_cell = neighbor
				found_next = true
				break
		
		if not found_next:
			break # This prevents infinite loops in case of a break in the chain

	return ordered_cells

func get_neighbors(cell: Vector2i) -> Array:
	var neighbors = []

	# Horizontal and vertical neighbors (4-way)
	neighbors.append(cell + Vector2i(1, 0))   # Right
	neighbors.append(cell + Vector2i(-1, 0))  # Left
	neighbors.append(cell + Vector2i(0, 1))   # Down
	neighbors.append(cell + Vector2i(0, -1))  # Up
	
	#if neighbors.size() > 0:
		#return neighbors

	# Diagonal neighbors (for 8-way)
	neighbors.append(cell + Vector2i(1, 1))   # Bottom-Right
	neighbors.append(cell + Vector2i(-1, 1))  # Bottom-Left
	neighbors.append(cell + Vector2i(1, -1))  # Top-Right
	neighbors.append(cell + Vector2i(-1, -1)) # Top-Left

	return neighbors
