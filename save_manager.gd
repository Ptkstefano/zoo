extends Node

var WaterCoverageLayer
var TerrainLayer
var PathLayer
var EnclosureLayer
var TerrainWangE
var TerrainWangS
var TerrainWangW
var TerrainWangN

#var enclosureManager
var enclosure_list = []

#var animalManager
var animal_list = []
var animal_data = {}

#var sceneryManager
var scenery_list = []

#var fixtureManager
var fixture_list = []

#var peepManager
var peepGroupList = []

#var buildingManager
var building_list = []

#var waterManager
var water_list = []

#var pathManager

var tilemap_layers = []

var thread : Thread

var main_save_path = 'user://save_game.json'
var backup_save_path = 'user://save_game_backup.json'

func _ready() -> void:
	SignalBus.save_game.connect(thread_save_game)
	thread = Thread.new()
	$AutoSaveTimer.timeout.connect(on_autosave)


func on_autosave():
	thread_save_game()

func start_save_manager():
	#var main_node = get_tree().root.get_node("Main")
	#var tilemaps = main_node.get_node("TileMap")
	var tilemaps = get_tree().get_first_node_in_group('TilemapManager')
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
	
	enclosure_list = get_tree().get_nodes_in_group('Enclosures')

	SignalBus.update_animals_cached_positions.emit()
	animal_list = get_tree().get_nodes_in_group('Animals')

	scenery_list = get_tree().get_nodes_in_group('Scenery')

	fixture_list = get_tree().get_nodes_in_group('Fixtures')

	water_list = get_tree().get_nodes_in_group('WaterBodies')

	building_list = get_tree().get_nodes_in_group('Buildings')

	SignalBus.update_peeps_cached_positions.emit()
	peepGroupList = get_tree().get_nodes_in_group('PeepGroups')
	
	


func thread_save_game():
	if !GameManager.game_running:
		return
	start_save_manager()
	if thread.is_alive():
		return
	thread.start(save_game)

func save_game():
	print('starting save')
	
	if(FileAccess.get_open_error() != OK):
		return
	var saveFile = FileAccess.open(main_save_path, FileAccess.WRITE)

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
		enclosure_data[i] = get_enclosure_data(enclosure).duplicate(true)
		i += 1
	save_data['enclosureData'] = enclosure_data
	
	## Save animal data
	i = 1
	for animal in animal_list:
		animal_data[i] = get_animal_data(animal).duplicate(true)
		i += 1

	save_data['animalData'] = animal_data
	
	## Save scenery data
	i = 1
	var scenery_data = {}
	for scenery in scenery_list:
		scenery_data[i] = get_scenery_data(scenery).duplicate(true)
		i += 1
	save_data['sceneryData'] = scenery_data
		
	## Save peep data - TODO
	i = 1
	var peep_group_data = {}
	for peep_group in peepGroupList:
		if is_instance_valid(peep_group):
			peep_group_data[i] = get_peep_group_data(peep_group).duplicate(true)
			i += 1
	save_data['peepGroupData'] = peep_group_data
	
	var zoo_manager_data = {}
	zoo_manager_data['next_enclosure_id'] = ZooManager.next_enclosure_id
	zoo_manager_data['next_animal_id'] = ZooManager.next_animal_id
	zoo_manager_data['next_building_id'] = ZooManager.next_building_id
	zoo_manager_data['next_scenery_id'] = ZooManager.next_scenery_id
	zoo_manager_data['reputation'] = ZooManager.reputation
	zoo_manager_data['review_list'] = ZooManager.review_list
	zoo_manager_data['entrance_price'] = ZooManager.entrance_price
	zoo_manager_data['zoo_entrance_open'] = ZooManager.zoo_entrance_open
	

	save_data['zoo_manager_data'] = zoo_manager_data
	
	
	## Save building data
	i = 1
	var building_data = {}
	for building in building_list:
		building_data[i] = get_building_data(building).duplicate(true)
		i += 1
	save_data['buildingData'] = building_data
	
	## Save water data
	i = 1
	var water_data = {}
	for water in water_list:
		if water is Lake:
			water_data[i] = get_water_data(water).duplicate(true)
			i += 1
	save_data['waterData'] = water_data
	
	## Save shelter data - TODO
	
	## Save fixture data
	i = 1
	var fixture_data = {}
	for fixture in fixture_list:
		fixture_data[i] = get_fixture_data(fixture).duplicate(true)
		i += 1
	save_data['fixtureData'] = fixture_data
	
	## Save finance data
	save_data['financeData'] = get_finance_data().duplicate(true)
	
	## Save time data
	save_data['timeData'] = get_time_data().duplicate(true)
	
	var json_data = JSON.stringify(save_data)
	
	if json_data.is_empty():
		print('save failed')
		return
		
	saveFile.store_string(json_data)
	
	var backupFile = FileAccess.open(backup_save_path, FileAccess.WRITE)
	backupFile.store_string(json_data)
	#saveFile.call_deferred('store_string', JSON.stringify(save_data))
	
	call_deferred('save_finished')
	
func save_finished():
	thread.wait_to_finish()
	print('Game saved')
	
	

func load_game():
	print('loading game')
	start_save_manager()
	
	var main_node = get_tree().root.get_node("Main")
	var animalManager = main_node.get_node("Objects").get_node('AnimalManager') as AnimalManager
	var sceneryManager = main_node.get_node("Objects").get_node('SceneryManager') as SceneryManager
	var enclosureManager = main_node.get_node("Objects").get_node("EnclosureManager") as EnclosureManager
	var fixtureManager = main_node.get_node("Objects").get_node('FixtureManager') as FixtureManager
	var waterManager = main_node.get_node("Objects").get_node('WaterManager') as WaterManager
	var buildingManager = main_node.get_node("Objects").get_node('BuildingManager') as BuildingManager
	var peepManager = main_node.get_node("Objects").get_node('PeepManager')
	var pathManager = main_node.get_node('PathManager') as PathManager
	
	
	
	var file = FileAccess.open(main_save_path, FileAccess.READ)
	if !file:
		return
		
	var data
	if file:
		var json = JSON.new()
		data = json.parse_string(file.get_as_text())  
		
		if !data: 
			var backup_file = FileAccess.open(backup_save_path, FileAccess.READ)
			data = json.parse_string(backup_file.get_as_text())  
			
	if !data:
		print('NO SAVE FILE FOUND')
		return

	for key in tilemap_layers.keys():
		if key == 'PathLayer':
			## Grabs all coordinates of given path atlas Y and builds it 
			var possible_path_atlas_y = {0: [], 1: []}
			for cell in data["tilemapData"][key]:
				if int(data["tilemapData"][key][cell].atlas_y) in possible_path_atlas_y.keys():
					possible_path_atlas_y[int(data["tilemapData"][key][cell].atlas_y)].append(Vector2i(int(data["tilemapData"][key][cell].x), int(data["tilemapData"][key][cell].y)))
			for atlas_y in possible_path_atlas_y:
				pathManager.build_path(possible_path_atlas_y[atlas_y], atlas_y)
					
			SignalBus.peep_navigation_changed.emit()
		else:
			if data["tilemapData"].has(key):
				for cell in data["tilemapData"][key]:
					var cell_data = data["tilemapData"][key][cell]
					tilemap_layers[key].set_cell(Vector2i(cell_data.x, cell_data.y), cell_data.source, Vector2i(cell_data.atlas_x, cell_data.atlas_y))
	
	
	if data.has('enclosureData'):
		for key in data["enclosureData"]:
			var enclosure_cells = []
			var fence_res = load(data["enclosureData"][key]['fence_res'])
			var enclosure_id = int(data["enclosureData"][key]['enclosure_id'])
			for cell in data["enclosureData"][key]['enclosure_cells']:
				enclosure_cells.append(Vector2i(data["enclosureData"][key]['enclosure_cells'][cell].x, data["enclosureData"][key]['enclosure_cells'][cell].y))
			var entrance_cell = null
			if data["enclosureData"][key]['enclosure_entrance']:
				entrance_cell = Vector2i(data["enclosureData"][key]['enclosure_entrance'].x, data["enclosureData"][key]['enclosure_entrance'].y)
			enclosureManager.build_enclosure(enclosure_id, enclosure_cells, entrance_cell, fence_res)
			if data["enclosureData"][key].has('feed_data'):
				enclosureManager.restore_enclosure_feed(enclosure_id, data["enclosureData"][key]['feed_data'])
				
		
	if data.has('animalData'):
		for key in data["animalData"]:
			var position = Vector2i(data["animalData"][key]['x_pos'], data["animalData"][key]['y_pos'])
			var animal_res = load(data['animalData'][key]['animal_res'])
			var animal_data = data['animalData'][key]
			animalManager.call_deferred('spawn_animal', position, animal_res, animal_data, false, null)
			
	if data.has('sceneryData'):
		for key in data["sceneryData"]:
			var position = Vector2i(data["sceneryData"][key]['x_pos'], data["sceneryData"][key]['y_pos'])
			if data["sceneryData"][key]['scenery_type'] == IdRefs.SCENERY_TYPES.VEGETATION:
				var res = load(data["sceneryData"][key]['vegetation_res'])
				sceneryManager.place_vegetation(position, res, null)
			elif data["sceneryData"][key]['scenery_type'] == IdRefs.SCENERY_TYPES.TREE:
				var res = load(data["sceneryData"][key]['tree_res'])
				sceneryManager.place_tree(position, res, null)
			elif data["sceneryData"][key]['scenery_type'] == IdRefs.SCENERY_TYPES.DECORATION:
				var res = load(data["sceneryData"][key]['decoration_res'])
				## TODO - Add is rotated to save data
				sceneryManager.place_decoration(position, res, false, null)
			elif data["sceneryData"][key]['scenery_type'] == IdRefs.SCENERY_TYPES.ROCK:
				var res = load(data["sceneryData"][key]['decoration_res'])
				sceneryManager.place_rock(position, res, null)
				
	if data.has('fixtureData'):
		for key in data["fixtureData"]:
			var position = Vector2i(data["fixtureData"][key]['x_pos'], data["fixtureData"][key]['y_pos'])
			var direction = int(data["fixtureData"][key].get('direction', 0))
			var fixture_res = load(data['fixtureData'][key]['fixture_res'])
			fixtureManager.call_deferred('place_fixture', position, fixture_res, true, direction)
	
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
			var building_data = { 'id':  data['buildingData'][key]['building_id']}

			if data['buildingData'][key].has('shop_data'):
				var products = {}
				var sold_units = {}
				for product in data['buildingData'][key]['shop_data']['product_data']['products']:
					products[product] = {
						'product_id': data['buildingData'][key]['shop_data']['product_data']['products'][product].get('product_id', 0),
						'current_price': data['buildingData'][key]['shop_data']['product_data']['products'][product].get('current_price', 0.0),
						'current_stock': data['buildingData'][key]['shop_data']['product_data']['products'][product].get('current_stock', 0),
						'auto_restock': data['buildingData'][key]['shop_data']['product_data']['products'][product].get('auto_restock', false)
					}
				
				var shop_stats = data['buildingData'][key]['shop_data']['shop_stats']
				
				## Id's have to be converted back into int
				for id in shop_stats['shop_product_stats'].keys():
					shop_stats['shop_product_stats'][int(id)] = shop_stats['shop_product_stats'][id]
					shop_stats['shop_product_stats'].erase(id)
					
				building_data['shop_data'] = {
					'products' = products,
					'shop_stats' = shop_stats
				}
				
			buildingManager.build_building(building_res, pos, is_rotated, building_data)
			
	if data.has('peepGroupData'):
		for key in data["peepGroupData"]:
			var groupData = {}
			if !data["peepGroupData"][key]:
				continue
			groupData['id'] = data["peepGroupData"][key]['id']
			groupData['spawn_location'] = Vector2(data["peepGroupData"][key]['x_pos'], data["peepGroupData"][key]['y_pos'])
			groupData['peep_count'] = data["peepGroupData"][key]['peep_count']
			groupData['observed_animals'] = data["peepGroupData"][key]['observed_animals']
			groupData['needs_hunger'] = data["peepGroupData"][key]['needs_hunger']
			groupData['needs_toilet'] = data["peepGroupData"][key]['needs_toilet']
			groupData['needs_rest'] = data["peepGroupData"][key]['needs_rest']
			groupData['desired_enclosure_ids'] = data["peepGroupData"][key].get('desired_enclosure_ids', [])
			groupData['min_product_level'] = data["peepGroupData"][key].get('min_product_level', 1)
			peepManager.instantiate_peep_group(groupData)
			
	if data.has('zoo_manager_data'):
		ZooManager.next_enclosure_id = int(data['zoo_manager_data']['next_enclosure_id'])
		ZooManager.next_animal_id = int(data['zoo_manager_data']['next_animal_id'])
		ZooManager.next_building_id = int(data['zoo_manager_data']['next_building_id'])
		ZooManager.next_scenery_id = int(data['zoo_manager_data']['next_scenery_id'])
		ZooManager.reputation = data['zoo_manager_data'].get('reputation', 3.0)
		ZooManager.review_list = data['zoo_manager_data'].get('review_list', [])
		ZooManager.entrance_price = data['zoo_manager_data'].get('entrance_price', 10.0)
		ZooManager.zoo_entrance_open = data['zoo_manager_data'].get('zoo_entrance_open', true)
		
	if data.has('financeData'):
		FinanceManager.current_money = data['financeData']['current_money']
		FinanceManager.monthly_stats = data['financeData'].get('monthly_stats', {})
		FinanceManager.current_month_stats = data['financeData'].get('current_month_stats', {month = TimeManager.current_month, income = {}, expenditures = {}})
		
	if data.has('timeData'):
		TimeManager.current_month = data['timeData']['current_month']
		TimeManager.current_year = data['timeData']['current_year']
		TimeManager.set_timer_time_left(data['timeData'].get('timer_time_left', TimeManager.default_month_time))
			
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
	if enclosure.entrance_door_cell:
		data['enclosure_entrance'] = {'x': enclosure.entrance_door_cell.x, 'y': enclosure.entrance_door_cell.y}
	else:
		data['enclosure_entrance'] = null
		
	data['feed_data'] = null
	if is_instance_valid(enclosure.animal_feed):
		var feed_data = {}
		feed_data['sprite_y'] = enclosure.animal_feed.sprite_y
		feed_data['amount'] = enclosure.animal_feed.amount
		feed_data['x'] = enclosure.animal_feed.pos_x
		feed_data['y'] = enclosure.animal_feed.pos_y
		data['feed_data'] = feed_data
		
	data['fence_res'] = enclosure.fence_res.get_path()
	return data
	
func get_animal_data(animal):
	var data = {}
	if !is_instance_valid(animal):
		return
	data['id'] = animal.id
	data['x_pos'] = animal.cached_global_position.x
	data['y_pos'] = animal.cached_global_position.y
	data['animal_res'] = animal.animal_res.get_path()
	data['needs_rest'] = animal.needs_rest
	data['needs_hunger'] = animal.needs_hunger
	data['needs_play'] = animal.needs_play
	data['animal_gender'] = animal.animal_gender
	data['is_animal_pregnant'] = animal.is_animal_pregnant
	data['months_pregnant'] = animal.months_pregnant
	data['is_looking_for_mate'] = animal.is_looking_for_mate
	data['is_infant'] = animal.is_infant
	data['animal_color_variation'] = animal.animal_color_variation
	data['months_of_life'] = animal.months_of_life
	data['months_in_zoo'] = animal.months_in_zoo
	return data

func get_peep_group_data(peep_group):
	if is_instance_valid(peep_group):
		var data = {}
		data['id'] = peep_group.id
		data['x_pos'] = peep_group.cached_position.x
		data['y_pos'] = peep_group.cached_position.y
		data['peep_count'] = peep_group.peep_count
		data['needs_rest'] = peep_group.needs_rest
		data['needs_hunger'] = peep_group.needs_hunger
		data['needs_toilet'] = peep_group.needs_toilet
		data['observed_animals'] = peep_group.observed_animals
		data['desired_enclosure_ids'] = peep_group.desired_enclosure_ids
		data['min_product_level'] = peep_group.min_product_level
		#data['visited_shops'] = peep_group.
		## TODO - Peep visited shops
		## TODO - Peep inventory
		return data
	

func get_scenery_data(scenery):
	var data = {}
	if !is_instance_valid(scenery):
		return
	var scenery_type = scenery.type
	data['scenery_type'] = scenery_type
	data['x_pos'] = scenery.cached_position.x
	data['y_pos'] = scenery.cached_position.y
	if scenery_type == IdRefs.SCENERY_TYPES.VEGETATION:
		#print('type vegetation')
		data['vegetation_res'] = scenery.vegetation_res.get_path()
	elif scenery_type == IdRefs.SCENERY_TYPES.TREE:
		data['tree_res'] = scenery.tree_res.get_path()
	elif scenery_type == IdRefs.SCENERY_TYPES.DECORATION:
		data['decoration_res'] = scenery.decoration_res.get_path()
	elif scenery_type == IdRefs.SCENERY_TYPES.ROCK:
		data['decoration_res'] = scenery.rock_res.get_path()
	return data

func get_fixture_data(fixture):
	var data = {}
	data['x_pos'] = fixture.placement_global_pos.x
	data['y_pos'] = fixture.placement_global_pos.y
	data['direction'] = fixture.direction
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

func get_finance_data():
	var data = {
		'current_money' = FinanceManager.current_money,
		'monthly_stats' = FinanceManager.monthly_stats,
		'current_month_stats' = FinanceManager.current_month_stats
	}
	return data


func get_building_data(building):
	var data = {}
	data['building_type'] = building.building_res.building_type
	data['building_id'] = building.id
	if building.building_res.building_type in [IdRefs.BUILDING_TYPES.SHOP, IdRefs.BUILDING_TYPES.RESTAURANT, IdRefs.BUILDING_TYPES.EATERY]:
		var shop_data = {}
		var products = {}
		for product in building.building_scene.available_products:
			products[product] = {
				'product_id': building.building_scene.available_products[product].product.id,
				'current_price': building.building_scene.available_products[product].current_price,
				'current_stock': building.building_scene.available_products[product].current_stock,
				'auto_restock': building.building_scene.available_products[product].auto_restock
			}
		var product_data = {
				'products': products,
			}
		shop_data['product_data'] = product_data
		shop_data['shop_stats'] = {
			'shop_product_stats' = building.building_scene.shop_product_data,
			'shop_earning_stats' = building.building_scene.shop_earning_data,
			'shop_expenditure_stats' = building.building_scene.shop_expenditure_data
			}
			
		data['shop_data'] = shop_data

	data['building_res'] = building.building_res.get_path()
	data['is_rotated'] = building.is_building_rotated
	var start_tile = { 'x_pos': building.start_tile.x, 'y_pos': building.start_tile.y }
	data['start_tile'] = start_tile

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
	
func get_time_data():
	var data = {
		"current_month": TimeManager.current_month,
		'current_year': TimeManager.current_year,
		'timer_time_left': TimeManager.get_timer_time_left()
	}
	return data
