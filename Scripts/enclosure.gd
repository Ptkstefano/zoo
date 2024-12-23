extends Node2D

class_name Enclosure

@export var enclosure_scene : PackedScene

var id : int

var enclosure_cells : Array[Vector2i] = []

var enclosure_animals = []
var enclosure_tree_ids = []

var enclosure_species : animal_resource

var fence_res : fence_resource

var animal_feed_scene : PackedScene = preload("res://AnimalFeed/animal_feed.tscn")
var animal_feed : AnimalFeed = null
var feed_position : Vector2

var vegetation_coverage : float
var water_availability : bool
var terrain_coverage : Dictionary
var available_shelters : Array[Shelter]
var herd_size : int
var cells_per_animal : float

var enclosure_central_point : Vector2

var entrance_cell : Vector2i
var entrance_door_cell : Vector2i

@onready var enclosure_tilemap = $EnclosureTiles
@onready var enclosure_fence_manager : EnclosureFenceManager = $EnclosureFenceManager


signal create_sibling_enclosure
signal enclosure_stats_updated

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enclosure_fence_manager.enclosure_tilemap = enclosure_tilemap
	SignalBus.obstacle_changed.connect(update_navigation_region)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_animal_destination():
	var random_cell = enclosure_cells.pick_random()
	var random_position = enclosure_tilemap.map_to_local(random_cell)
	return random_position

func calculate_enclosure_stats():
	terrain_coverage = TileMapRef.get_terrain_coverage(enclosure_cells)
	water_availability = TileMapRef.get_water_availability(enclosure_cells)
	var enclosure_vegetation = $VegetationDetectionArea.get_overlapping_areas()
	await get_tree().create_timer(0.1).timeout
	enclosure_tree_ids.clear()
	var vegetation_weight_sum = 0
	for area in enclosure_vegetation:
		var main_node = area.get_parent()
		vegetation_weight_sum += main_node.vegetation_weight
		if main_node is SceneryTree:
			if main_node.tree_res.id not in enclosure_tree_ids:
				enclosure_tree_ids.append(main_node.tree_res.id)
		
	vegetation_coverage = vegetation_weight_sum / enclosure_cells.size()
	herd_size = enclosure_animals.size()
	cells_per_animal = float(enclosure_cells.size()) / float(enclosure_animals.size())
	enclosure_stats_updated.emit()
	
func get_enclosure_trees():
	return enclosure_tree_ids
	
	
func add_shelter(shelter):
	available_shelters.append(shelter)

func add_cells(coordinates, fence_res):
	if fence_res:
		fence_res = fence_res
	for coordinate in coordinates:
		if !enclosure_cells.has(coordinate):
			enclosure_cells.append(coordinate)
	set_enclosure_tilemap_cells()
	build_fence()
	if entrance_door_cell:
		call_deferred("place_entrance", entrance_door_cell)
	update_central_point()
	call_deferred('update_navigation_region')
	call_deferred("calculate_enclosure_stats")
	update_enclosure_area()

			
func remove_cells(coordinates):
	for coordinate in coordinates:
		enclosure_tilemap.set_cell(coordinate, -1, Vector2i(-1,-1))
		if enclosure_cells.has(coordinate):
			enclosure_cells.erase(coordinate)
		if entrance_door_cell and enclosure_cells.has(entrance_door_cell):
			call_deferred("place_entrance", entrance_door_cell)
			
	if enclosure_cells.size() == 0:
		remove_enclosure()
		return
	
	detect_continuity()
	set_enclosure_tilemap_cells()
	build_fence()
	redistribute_animals()
	update_central_point()
	update_navigation_region()
	call_deferred("calculate_enclosure_stats")
	update_enclosure_area()
	
func place_entrance(cell):
	var new_entrance = $EnclosureFenceManager.place_entrance(cell)
	if new_entrance:
		entrance_cell = new_entrance
		entrance_door_cell = cell
		
	#feed_position = TileMapRef.map_to_local(Vector2(entrance_door_cell.x, entrance_door_cell.y + 1))
	ZooManager.update_zoo_enclosure(self)
	
	
func detect_continuity():
	## Figures out if current enclosure was broken into multiple enclosures and instantiates newly created enclosures as siblings
	if enclosure_cells.size() == 0:
		return
	var iterated_coordinates = []
	var existing_enclosures = {}
	var n_enclosures = 0
	
	var i = 0
	while(iterated_coordinates.size() != enclosure_cells.size()):
		var starting_cell = find_first_coordinate_not_matching(iterated_coordinates)
		n_enclosures += 1
		var current_enclosure_cells : Array[Vector2i] = []
		for coordinate in get_isolated_enclosure(enclosure_cells[starting_cell]):
			if !iterated_coordinates.has(coordinate):
				current_enclosure_cells.append(Vector2i(coordinate.x, coordinate.y))
				iterated_coordinates.append(Vector2i(coordinate.x, coordinate.y))
		existing_enclosures[i] = current_enclosure_cells
		i += 1
	
	if existing_enclosures.keys().size() > 1:
		enclosure_cells = existing_enclosures[0]
		for key in existing_enclosures.keys():
			if key == 0:
				continue
			else:
				create_sibling(existing_enclosures[key])
		
func get_isolated_enclosure(starting_coordinate):
	var current_iterated_coordinates = [starting_coordinate]
	for coordinate in current_iterated_coordinates:
		var adjacent_cells = Helpers.get_adjacent(coordinate)
		for adjacent_cell in adjacent_cells:
			if enclosure_cells.has(adjacent_cell):
				if !current_iterated_coordinates.has(adjacent_cell):
					current_iterated_coordinates.append(adjacent_cell)
	return current_iterated_coordinates
					
		
func find_first_coordinate_not_matching(iterated_coordinates):
	for coordinate in enclosure_cells:
		if coordinate not in iterated_coordinates:
			return enclosure_cells.find(coordinate)
			
func create_sibling(cells):
	create_sibling_enclosure.emit(cells, fence_res, null)
	#var sibling = enclosure_scene.instantiate()
	#add_sibling(sibling)
	#remove_cells(cells)
	#sibling.add_cells(cells, fence_res)
	
func build_fence():
	## Actually instantiates the visual nodes of the enclosure
	enclosure_fence_manager.fence_res = fence_res
	enclosure_fence_manager.build_enclosure_fence(enclosure_cells)
	

func add_animal(animal):
	if enclosure_species == null:
		enclosure_species = animal.animal_res
		ZooManager.update_zoo_enclosure(self)
		#id = ZooManager.generate_enclosure_id()
	enclosure_animals.append(animal)
	animal.animal_removed.connect(remove_animal)
	call_deferred("calculate_enclosure_stats")
	
func set_id(i : int):
	id = i
	ZooManager.add_zoo_enclosure(self)
	
func remove_animal(animal):
	enclosure_animals.erase(animal)
	call_deferred("calculate_enclosure_stats")
	if enclosure_animals.size() == 0:
		enclosure_species = null
		

func redistribute_animals():
	for animal in enclosure_animals:
		animal.global_position = enclosure_tilemap.map_to_local(enclosure_cells.pick_random())
		animal.update_cached_position()

func remove_enclosure():
	for animal in enclosure_animals:
		animal.remove_animal()
		
	ZooManager.remove_zoo_enclosure(self)
	queue_free()

func update_central_point():
	var cells = $EnclosureFenceManager.fence_cells
	var sum_x: float = 0.0
	var sum_y: float = 0.0
	var num_cells: int = cells.size()

	for cell in cells:
		sum_x += cell.x
		sum_y += cell.y

	var centroid_x: float = sum_x / num_cells
	var centroid_y: float = sum_y / num_cells
	
	var central_point = Vector2(centroid_x, centroid_y)

	enclosure_central_point = Helpers.get_global_pos_of_cell(central_point)
	
	
func update_navigation_region():
	if GameManager.game_running:
		$LandRegion.call_deferred('bake_navigation_polygon')
		$WaterRegion.call_deferred('bake_navigation_polygon')
	
func update_enclosure_area():
	var coordinates = []
	#var ordered_cells = order_edge_cells($EnclosureManager.enclosure_cells)
	var ordered_cells = order_edge_cells($EnclosureFenceManager.fence_cells)
	for cell in ordered_cells:
		var localpos = TileMapRef.map_to_local(cell)
		if localpos not in coordinates:
			coordinates.append(localpos)

	$VegetationDetectionArea/CollisionPolygon2D.polygon = coordinates


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

func open_door():
	$EnclosureFenceManager.open_door()

func add_animal_feed():
	## TODO - Spawn feed in a specific cell
	var feed_y = 0
	if enclosure_animals.is_empty():
		return
	else:
		feed_y = enclosure_animals[0].animal_res.feed
	if !animal_feed:
		animal_feed = animal_feed_scene.instantiate()
		animal_feed.sprite_y = feed_y
		#var random_position = TileMapRef.map_to_local(enclosure_cells.pick_random())
		#animal_feed.global_position = random_position
		
		var entrance_cell = $EnclosureFenceManager.entrance_node.cell
		var dir = $EnclosureFenceManager.entrance_node.dir
		var feed_cell 
		## Feed is placed one tile ahead of entrance
		if dir == 0:
			feed_cell = Vector2(entrance_cell.x, entrance_cell.y+1)
		elif dir == 1:
			feed_cell = Vector2(entrance_cell.x+1, entrance_cell.y)
		elif dir == 2:
			feed_cell = Vector2(entrance_cell.x, entrance_cell.y-1)
		elif dir == 3:
			feed_cell = Vector2(entrance_cell.x-1, entrance_cell.y)
		
		print ('A')
		
		animal_feed.global_position = TileMapRef.map_to_local(feed_cell)
		add_child(animal_feed)
	else:
		animal_feed.fill()

func set_enclosure_tilemap_cells():
	for cell in enclosure_tilemap.get_used_cells():
		enclosure_tilemap.set_cell(cell, -1, Vector2(-1, -1))
	for coordinate in enclosure_cells:
		enclosure_tilemap.set_cell(coordinate, 1, Vector2i(1, 1))
		
