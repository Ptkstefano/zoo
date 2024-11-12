extends Node

var WaterCoverageLayer
var TerrainLayer
var PathLayer
var EnclosureLayer
var TerrainWangE
var TerrainWangS
var TerrainWangW
var TerrainWangN

var enclosureManager
var enclosure_list = []

var animalManager
var animal_list = []
var animal_data = {}

var sceneryManager
var scenery_list = []

var fixtureManager
var fixture_list = []

var peepManager
var peepGroupList = []

var buildingManager
var building_list = []

var waterManager
var water_list = []

var tilemap_layers = []

var thread : Thread

func _ready() -> void:
	#SignalBus.save_game.connect(thread_save_game)
	#SignalBus.save_new_scenery.connect(save_new_scenery)
	thread = Thread.new()
	#SignalBus.game_started.connect(load_game)


func start_save_manager():
	var main_node = get_tree().root.get_node("Main")
	var tilemaps = main_node.get_node("TileMap")
	WaterCoverageLayer = tilemaps.get_node("WaterCoverageLayer")
	TerrainLayer = tilemaps.get_node("TerrainLayer")
	PathLayer =  tilemaps.get_node("PathLayer")
	EnclosureLayer =  tilemaps.get_node("EnclosureLayer")
	TerrainWangE =  tilemaps.get_node("TerrainLayer/TerrainWang_E")
	TerrainWangS =  tilemaps.get_node("TerrainLayer/TerrainWang_S")
	TerrainWangW =  tilemaps.get_node("TerrainLayer/TerrainWang_W")
	TerrainWangN = tilemaps.get_node("TerrainLayer/TerrainWang_N")
	tilemap_layers = {
		'WaterCoverageLayer': WaterCoverageLayer,
		'TerrainLayer': TerrainLayer,
		'PathLayer': PathLayer,
		'EnclosureLayer': EnclosureLayer,
		'TerrainWangE':TerrainWangE,
		'TerrainWangS': TerrainWangS, 
		'TerrainWangW': TerrainWangW,
		'TerrainWangN': TerrainWangN
	}
	
	enclosureManager = main_node.get_node("Objects").get_node("EnclosureManager") as EnclosureManager
	enclosure_list = enclosureManager.get_children()
	animalManager = main_node.get_node("Objects").get_node('AnimalManager') as AnimalManager
	animal_list = animalManager.get_children()
	sceneryManager = main_node.get_node("Objects").get_node('SceneryManager') as SceneryManager
	scenery_list = sceneryManager.get_children()
	fixtureManager = main_node.get_node("Objects").get_node('FixtureManager') as FixtureManager
	fixture_list = fixtureManager.get_children()
	waterManager = main_node.get_node("Objects").get_node('WaterManager') as WaterManager
	water_list = waterManager.get_children()
	buildingManager = main_node.get_node("Objects").get_node('BuildingManager') as BuildingManager
	building_list = buildingManager.get_children()
	peepManager = main_node.get_node("Objects").get_node('PeepManager')
	peepManager.update_peeps_cached_positions()
	peepGroupList = peepManager.peep_groups
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == 4194336:
				## F5 
				thread_save_game()
			if event.keycode == 4194340:
				## F9
				load_game()

func thread_save_game():
	## Avoids saving the game while it is loading
	if !GameManager.game_running:
		return
	start_save_manager()
	if thread.is_alive():
		return
	thread.start(save_game)

func save_game():
	
	if(FileAccess.get_open_error() != OK):
		return
	var saveFile = FileAccess.open("user://save_game.json", FileAccess.WRITE)

	var save_data = {}
		
	## Save tilemap data
	var tilemap_data = {}
	for tilemap in tilemap_layers.keys():
		tilemap_data[tilemap] = get_tilemap_data(tilemap_layers[tilemap])
	save_data['tilemapData'] = tilemap_data
			
	## Save enclosure data
	var enclosure_data = {}
	var i = 1
	
	for enclosure in enclosure_list:
		enclosure_data[i] = get_enclosure_data(enclosure)
		i += 1
	save_data['enclosureData'] = enclosure_data
	
	## Save animal data
	i = 1
	for animal in animal_list:
		animal_data[i] = get_animal_data(animal)
		i += 1

	save_data['animalData'] = animal_data
	
	## Save scenery data
	i = 1
	var scenery_data = {}
	for scenery in scenery_list:
		scenery_data[i] = get_scenery_data(scenery)
		i += 1
	save_data['sceneryData'] = scenery_data
		
	## Save peep data - TODO
	i = 1
	var peep_group_data = {}
	for peep_group in peepGroupList:
		peep_group_data[i] = get_peep_group_data(peep_group)
		i += 1
	save_data['peepGroupData'] = peep_group_data
	
	var zoo_manager_data = {}
	zoo_manager_data['next_enclosure_id'] = ZooManager.next_enclosure_id
	save_data['zoo_manager_data'] = zoo_manager_data
	
	
	## Save building data - TODO
	i = 1
	var building_data = {}
	for building in building_list:
		building_data[i] = get_building_data(building)
		i += 1
	save_data['buildingData'] = building_data
	
	## Save water data
	i = 1
	var water_data = {}
	for water in water_list:
		if water is Lake:
			water_data[i] = get_water_data(water)
			i += 1
	save_data['waterData'] = water_data
	
	## Save shelter data - TODO
	
	## Save fixture data
	i = 1
	var fixture_data = {}
	for fixture in fixture_list:
		fixture_data[i] = get_fixture_data(fixture)
		i += 1
	save_data['fixtureData'] = fixture_data
	
	var json_data = JSON.stringify(save_data)
	
	if json_data.is_empty():
		print('save failed')
		return
		
	saveFile.store_string(json_data)
	#saveFile.call_deferred('store_string', JSON.stringify(save_data))
	
	call_deferred('save_finished')
	
func save_finished():
	thread.wait_to_finish()
	print('Game saved')
	

func load_game():
	start_save_manager()
	var file = FileAccess.open("user://save_game.json", FileAccess.READ)
	if !file:
		return
	if file:
		var json = JSON.new()
		var data = json.parse_string(file.get_as_text())  
		
		if !data:
			return

		for tilemap in tilemap_layers.keys():
			if data["tilemapData"].has(tilemap):
				for cell in data["tilemapData"][tilemap]:
					var cell_data = data["tilemapData"][tilemap][cell]
					tilemap_layers[tilemap].set_cell(Vector2i(cell_data.x, cell_data.y), cell_data.source, Vector2i(cell_data.atlas_x, cell_data.atlas_y))
		
		
		if data.has('enclosureData'):
			for key in data["enclosureData"]:
				var enclosure_cells = []
				var fence_res = load(data["enclosureData"][key]['fence_res'])
				var enclosure_id = int(data["enclosureData"][key]['enclosure_id'])
				for cell in data["enclosureData"][key]['enclosure_cells']:
					enclosure_cells.append(Vector2i(data["enclosureData"][key]['enclosure_cells'][cell].x, data["enclosureData"][key]['enclosure_cells'][cell].y))
				enclosureManager.build_enclosure(enclosure_cells, fence_res, enclosure_id)
			
		if data.has('animalData'):
			for key in data["animalData"]:
				var position = Vector2i(data["animalData"][key]['x_pos'], data["animalData"][key]['y_pos'])
				var animal_res = load(data['animalData'][key]['animal_res'])
				var stats = {'needs_hunger': data['animalData'][key]['needs_hunger'],
							'needs_rest': data['animalData'][key]['needs_rest'],
							'needs_playr': data['animalData'][key]['needs_play']
				}
				animalManager.call_deferred('spawn_animal', position, animal_res, stats)
				
		if data.has('sceneryData'):
			for key in data["sceneryData"]:
				var position = Vector2i(data["sceneryData"][key]['x_pos'], data["sceneryData"][key]['y_pos'])
				if data["sceneryData"][key]['scenery_type'] == IdRefs.SCENERY_TYPES.VEGETATION:
					var res = load(data["sceneryData"][key]['vegetation_res'])
					sceneryManager.place_vegetation(position, res)
				elif data["sceneryData"][key]['scenery_type'] == IdRefs.SCENERY_TYPES.TREE:
					var res = load(data["sceneryData"][key]['tree_res'])
					sceneryManager.place_tree(position, res)
				elif data["sceneryData"][key]['scenery_type'] == IdRefs.SCENERY_TYPES.DECORATION:
					var res = load(data["sceneryData"][key]['decoration_res'])
					sceneryManager.place_decoration(position, res)
					
		if data.has('fixtureData'):
			for key in data["fixtureData"]:
				var position = Vector2i(data["fixtureData"][key]['x_pos'], data["fixtureData"][key]['y_pos'])
				var fixture_res = load(data['fixtureData'][key]['fixture_res'])
				fixtureManager.call_deferred('place_fixture', position, fixture_res)
		
		if data.has('waterData'):
			for key in data["waterData"]:
				var line_points = []
				for point in data["waterData"][key]:
					var vector = Vector2(data["waterData"][key][point]['x_pos'], data["waterData"][key][point]['y_pos'])
					line_points.append(vector)
				waterManager.call_deferred('create_water_body', line_points)
				
		if data.has('buildingData'):
			for key in data['buildingData']:
				# (building_res, pos, rotate, coords)
				var building_res = load(data['buildingData'][key]['building_res'])
				var pos = Vector2(data['buildingData'][key]['start_tile']['x_pos'], data['buildingData'][key]['start_tile']['y_pos'])
				var is_rotated = data['buildingData'][key]['is_rotated']
				var used_coords = []
				for entry in data["buildingData"][key]['used_coordinates']:
					var vector = Vector2(data["buildingData"][key]['used_coordinates'][entry]['x_pos'], data["buildingData"][key]['used_coordinates'][entry]['y_pos'])
					used_coords.append(vector)
				buildingManager.build_building(building_res, pos, is_rotated, used_coords)
				
		if data.has('peepGroupData'):
			for key in data["peepGroupData"]:
				var groupData = {}
				groupData['spawn_location'] = Vector2(data["peepGroupData"][key]['x_pos'], data["peepGroupData"][key]['y_pos'])
				groupData['peep_count'] = data["peepGroupData"][key]['peep_count']
				groupData['observed_animals'] = data["peepGroupData"][key]['observed_animals']
				groupData['needs_hunger'] = data["peepGroupData"][key]['needs_hunger']
				groupData['needs_toilet'] = data["peepGroupData"][key]['needs_toilet']
				groupData['needs_rest'] = data["peepGroupData"][key]['needs_rest']
				groupData['desired_destinations_id'] = data["peepGroupData"][key]['desired_destinations_id']
				peepManager.instantiate_peep_group(groupData)
				
		if data.has('zoo_manager_data'):
			ZooManager.next_enclosure_id = data['zoo_manager_data']['next_enclosure_id']
				
		SignalBus.peep_navigation_changed.emit()

func get_tilemap_data(tilemap):
	var data = {}
	for x in range(-45, 45):
		for y in range(-45, 45):
			var coords = Vector2i(x, y)
			var tile_data = {} 
			tile_data['atlas_x'] = tilemap.get_cell_atlas_coords(coords).x
			tile_data['atlas_y'] = tilemap.get_cell_atlas_coords(coords).y
			tile_data['source'] = tilemap.get_cell_source_id(coords)
			tile_data['x'] = x
			tile_data['y'] = y
			data[str(coords)] = tile_data
	return data

func get_enclosure_data(enclosure):
	var data = {}
	var enclosure_cells = {}
	if !enclosure:
		return
	var i = 1
	for cell in enclosure.enclosure_cells:
		var tile_data = {}
		tile_data['x'] = cell.x
		tile_data['y'] = cell.y
		enclosure_cells[i] = tile_data
		i += 1
	data['enclosure_cells'] = enclosure_cells
	data['enclosure_id'] = enclosure.id
	data['enclosure_animals'] = enclosure.enclosure_animals
	data['fence_res'] = enclosure.fence_res.get_path()
	return data
	
func get_animal_data(animal):
	var data = {}
	if !is_instance_valid(animal):
		return
	data['x_pos'] = animal.cached_global_position.x
	data['y_pos'] = animal.cached_global_position.y
	data['animal_res'] = animal.animal_res.get_path()
	data['needs_rest'] = animal.needs_rest
	data['needs_hunger'] = animal.needs_hunger
	data['needs_play'] = animal.needs_play

	return data

func get_peep_group_data(peep_group):
	var data = {}
	data['x_pos'] = peep_group.cached_position.x
	data['y_pos'] = peep_group.cached_position.y
	data['peep_count'] = peep_group.peep_count
	data['needs_rest'] = peep_group.needs_rest
	data['needs_hunger'] = peep_group.needs_hunger
	data['needs_toilet'] = peep_group.needs_toilet
	data['observed_animals'] = peep_group.observed_animals
	data['desired_destinations_id'] = peep_group.desired_enclosures_id
	## TODO - Peep visited shops
	## TODO - Peep inventory
	return data
	

func get_scenery_data(scenery):
	var data = {}
	var scenery_type = scenery.type
	data['scenery_type'] = scenery_type
	data['x_pos'] = scenery.cached_position.x
	data['y_pos'] = scenery.cached_position.y
	if scenery_type == IdRefs.SCENERY_TYPES.VEGETATION:
		data['vegetation_res'] = scenery.vegetation_res.get_path()
	elif scenery_type == IdRefs.SCENERY_TYPES.TREE:
		data['tree_res'] = scenery.tree_res.get_path()
	elif scenery_type == IdRefs.SCENERY_TYPES.DECORATION:
		data['decoration_res'] = scenery.decoration_res.get_path()
	return data

func get_fixture_data(fixture):
	var data = {}
	data['x_pos'] = fixture.cached_position.x
	data['y_pos'] = fixture.cached_position.y
	data['fixture_res'] = fixture.fixture_res.get_path()
	return data

func get_water_data(water):
	var data = {}
	var i = 1
	for point in water.line_points:
		var cell = {}
		cell = { 'x_pos': point.x, 'y_pos': point.y }
		data[i] = cell
		i += 1
	return data

func get_building_data(building):
	var data = {}
	data['building_type'] = building.building_type
	data['building_res'] = building.building_res.get_path()
	data['is_rotated'] = building.is_building_rotated
	var start_tile = { 'x_pos': building.start_tile.x, 'y_pos': building.start_tile.y }
	data['start_tile'] = start_tile
	var used_coordinates = {}
	var i = 0
	for coordinate in building.used_coordinates:
		coordinate = { 'x_pos': coordinate.x, 'y_pos': coordinate.y }
		used_coordinates[i] = coordinate
		i += 1
	data['used_coordinates'] = used_coordinates
	## TODO - Restore building products and stats

	return data

	
func save_new_scenery(scenery):
	if(FileAccess.get_open_error() != OK):
		return
	var saveFile = FileAccess.open("user://save_game.json", FileAccess.READ_WRITE)
	
	var save_content = saveFile.get_as_text()

	
	var save_data = JSON.parse_string(save_content)
	saveFile.close()
	if save_data.has('sceneryData'):
		var last_key = save_data['sceneryData'].size()
		save_data['sceneryData'][last_key + 1] = get_scenery_data(scenery)
	
	var json_data = JSON.stringify(save_data)
	
	if json_data.is_empty():
		print('save failed')
		return
		
	saveFile.store_string(json_data)
	saveFile.close()
	print('saved scenery')
	
