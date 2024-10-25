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
var enclosureList = []

var animalManager
var animalList = []
var animal_data = {}

var sceneryManager
var sceneryList = []

var tilemap_layers = []

var thread : Thread

func _ready() -> void:
	SignalBus.save_game.connect(thread_save_game)
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
	
	enclosureManager = main_node.get_node("EnclosureManager") as EnclosureManager
	enclosureList = enclosureManager.get_children()
	animalManager = main_node.get_node("Objects").get_node('AnimalManager') as AnimalManager
	animalList = animalManager.get_children()
	sceneryManager = main_node.get_node("Objects").get_node('SceneryManager') as SceneryManager
	sceneryList = sceneryManager.get_children()

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
	
	for enclosure in enclosureList:
		enclosure_data[i] = get_enclosure_data(enclosure)
		i += 1
	save_data['enclosureData'] = enclosure_data
	
	## Save animal data
	i = 1
	for animal in animalList:
		animal_data[i] = get_animal_data(animal)
		i += 1

	save_data['animalData'] = animal_data
	
	## Save scenery data - TODO
	i = 1
	var scenery_data = {}
	for scenery in sceneryList:
		scenery_data[i] = get_scenery_data(scenery)
		i += 1
	save_data['sceneryData'] = scenery_data
		
	
	## Save peep data - TODO
	
	## Save building data - TODO
	
	## Save fixture data - TODO
		
	saveFile.store_string(JSON.stringify(save_data))
	
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
		var data = json.parse_string(file.get_as_text())  # Parse the file content

		for tilemap in tilemap_layers.keys():
			if data["tilemapData"].has(tilemap):
				for cell in data["tilemapData"][tilemap]:
					var cell_data = data["tilemapData"][tilemap][cell]
					tilemap_layers[tilemap].set_cell(Vector2i(cell_data.x, cell_data.y), cell_data.source, Vector2i(cell_data.atlas_x, cell_data.atlas_y))
		
		
		if data.has('enclosureData'):
			for key in data["enclosureData"]:
				var enclosure_cells = []
				var fence_res = load(data["enclosureData"][key]['fence_res'])
				for cell in data["enclosureData"][key]['enclosure_cells']:
					enclosure_cells.append(Vector2i(data["enclosureData"][key]['enclosure_cells'][cell].x, data["enclosureData"][key]['enclosure_cells'][cell].y))
				enclosureManager.build_enclosure(enclosure_cells, fence_res)
			
		if data.has('animalData'):
			for key in data["animalData"]:
				var position = Vector2i(data["animalData"][key]['x_pos'], data["animalData"][key]['y_pos'])
				var animal_res = load(data['animalData'][key]['animal_res'])
				var stats = {'needs_hunger': data['animalData'][key]['needs_hunger'],
							'needs_rest': data['animalData'][key]['needs_rest'],
							'needs_playr': data['animalData'][key]['needs_play']
				}
				animalManager.call_deferred('spawn_animal', position, animal_res, stats)
				
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
	var i = 1
	for cell in enclosure.enclosure_cells:
		var tile_data = {}
		tile_data['x'] = cell.x
		tile_data['y'] = cell.y
		enclosure_cells[i] = tile_data
		i += 1
	data['enclosure_cells'] = enclosure_cells
	data['enclosure_animals'] = enclosure.enclosure_animals
	data['fence_res'] = enclosure.fence_res.get_path()
	return data
	
func get_animal_data(animal):
	var data = {}
	data['x_pos'] = animal.cached_global_position.x
	data['y_pos'] = animal.cached_global_position.y
	data['animal_res'] = animal.animal_res.get_path()
	data['needs_rest'] = animal.needs_rest
	data['needs_hunger'] = animal.needs_hunger
	data['needs_play'] = animal.needs_play
	return data

func get_scenery_data(scenery):
	var data = {}
	var scenery_class = scenery.get_class() 
	data['scenery_type'] = scenery_class
	data['x_pos'] = scenery.cached_position.x
	data['y_pos'] = scenery.cached_position.x
	if scenery_class == 'SceneryVegetation':
		data['vegetation_res'] = scenery.vegetation_res.get_path()
	elif scenery_class == 'SceneryTree':
		data['tree_res'] = scenery.tree_res.get_path()
	elif scenery_class == 'SceneryDecoration':
		data['decoration_res'] = scenery.decoration_res.get_path()
	return data
