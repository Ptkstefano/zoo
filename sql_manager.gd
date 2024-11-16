extends Node

var db_path = "user://Savegame/savegame.db"
var database : SQLite

var peep_thread: Thread
var construction_thread: Thread
var data_thread: Thread

var construction_save_queue = []

func _ready() -> void:
	setup_save_folder()
	#peep_thread = Thread.new()
	construction_thread = Thread.new()
	#data_thread = Thread.new()
	
	$ConstructionQueueTimer.timeout.connect(iterate_construction_save_queue)
	
	#SignalBus.save_path_changes.connect(append_to_construction_save_queue)
	#SignalBus.save_terrain_changes.connect(append_to_construction_save_queue)
	#SignalBus.save_new_enclosure.connect(append_to_construction_save_queue)
	#SignalBus.save_update_enclosure.connect(append_to_construction_save_queue)
	#SignalBus.save_new_animal.connect(append_to_construction_save_queue)
	#SignalBus.save_new_scenery.connect(append_to_construction_save_queue)
	#
	#SignalBus.save_new_peep_group.connect(create_peep_group_threaded)
	#SignalBus.save_update_peep_group.connect(update_peep_group_threaded)
	#SignalBus.save_remove_peep_group.connect(remove_peep_group_threaded)
	#SignalBus.save_zoo_management.connect(update_zoo_management_threaded)
	database = SQLite.new()
	database.verbosity_level = SQLite.VerbosityLevel.NORMAL
	if !FileAccess.file_exists(db_path):
		create_save_file()
	else:
		return

func setup_save_folder():
	var dir = DirAccess.open("user://")
	dir.make_dir("Savegame")

	
func new_save():
	var dir_access = DirAccess.open("user://Savegame/")
	dir_access.remove_absolute(db_path)
	create_save_file()
	
func append_to_construction_save_queue(data):
	construction_save_queue.append(data)
	iterate_construction_save_queue()
	$ConstructionQueueTimer.start()
	
func iterate_construction_save_queue():
	print('iterate')
	if construction_save_queue.size() > 0:
		save_construction_data(construction_save_queue[0])
	else:
		$ConstructionQueueTimer.stop()
	
func save_construction_data(data):
	if construction_thread.is_alive():
		return
	else:
		if data.savetype == IdRefs.SAVE_TYPES.PATH:
			print('a')
			#construction_thread.start(save_path.bind(data))
			#construction_thread.start(save_path.bind(data))
			save_path(data)
		if data.savetype == IdRefs.SAVE_TYPES.TERRAIN:
			print('a')
			#construction_thread.start(save_path.bind(data))
			construction_thread.start(save_terrain.bind(data))
			#save_terrain(data)
		if data.savetype == IdRefs.SAVE_TYPES.NEW_ENCLOSURE:
			print('a')
			#construction_thread.start(save_path.bind(data))
			construction_thread.start(create_enclosure.bind(data))
			#create_enclosure(data)
		if data.savetype == IdRefs.SAVE_TYPES.UPDATE_ENCLOSURE:
			print('a')
			construction_thread.start(update_enclosure.bind(data))
			#update_enclosure(data)


func update_zoo_management(data):
	database.open_db()
	var query_string : String = "UPDATE zoo_management SET reputation = ?, next_enclosure_id = ?, next_animal_id = ?, next_enclosure_id = ? WHERE id == 0"
	database.query_with_bindings(query_string, [data.reputation, data.next_enclosure_id, data.next_animal_id, data.next_enclosure_id])
	database.close_db()
	call_deferred('save_finished_data')

func save_path(data):
	database.open_db()
	print('b')
	var condition : String
	var i = 1
	for coord in data.coordinates:
		condition += str(coord)
		if i != data.coordinates.size():
			condition += ', '
		i += 1
	var query_string : String = "UPDATE paths SET atlas_y = "+str(data.atlas_y)+" WHERE (pos_x, pos_y) IN (" + condition + ")"
	database.query(query_string)
	database.close_db()
	construction_save_queue.erase(data)
	return
	#save_finished_construction(data)

func save_terrain(data):
	database.open_db()
	var condition : String
	var i = 1
	for coord in data.coordinates:
		condition += str(coord)
		if i != data.coordinates.size():
			condition += ', '
		i += 1
	var query_string : String = "UPDATE terrain SET atlas_y = "+str(data.atlas_y)+" WHERE (pos_x, pos_y) IN (" + condition + ")"
	database.query(query_string)
	database.close_db()
	construction_save_queue.erase(data)
	#save_finished_construction(data)

func create_enclosure(data):
	#database.open_db()
	var formated_cells = []
	for cell in data.cells:
		formated_cells.append({"x": cell.x, "y": cell.y})

	var query = "INSERT INTO enclosures (id, cells,  resource) VALUES (?, ?, ?)"
	database.query_with_bindings(query, [data.id, JSON.stringify(formated_cells), data.res_path])
	
	#database.close_db()
	save_finished_construction(data)

func update_enclosure(data):
	database.open_db()
	var formated_cells = []
	for cell in data.cells:
		formated_cells.append({"x": cell.x, "y": cell.y}) 
		
	var formated_entrance = {"x": data.entrance_door_cell.x, "y": data.entrance_door_cell.y}
	

	var query = "UPDATE enclosures SET cells = ?, entrance_cell = ?, resource = ? WHERE id = ?"
	database.query_with_bindings(query, [JSON.stringify(formated_cells), JSON.stringify(formated_entrance), data.res_path, data.id])
	
	database.close_db()
	save_finished_construction(data)
#func save_enclosure(id, cells, entrance, res_path):


func create_animal(id, coordinates, res_path):
	database.open_db()
	var formated_coordinates = {"x": coordinates.x, "y": coordinates.y}
	var query = "INSERT INTO animals (id, coordinates, resource) VALUES (?, ?, ?)"
	database.query_with_bindings(query, [id, JSON.stringify(formated_coordinates), res_path])
	database.close_db()
	call_deferred('save_finished_construction')

func create_scenery(scenery_type, id, coordinates, res_path):
	database.open_db()
	var formated_coordinates = {"x": coordinates.x, "y": coordinates.y}
	var query = "INSERT INTO scenery (id, scenery_type, coordinates, resource) VALUES (?, ?, ?, ?)"
	database.query_with_bindings(query, [id, scenery_type, JSON.stringify(formated_coordinates), res_path])
	database.close_db()
	call_deferred('save_finished_construction')

func create_peep_group(id, peep_count, desired_destinations):
	database.open_db()
	var query = "INSERT INTO peep_groups (id, peep_count, desired_destinations, needs_hunger, needs_rest, needs_toilet, observed_animals, modifiers) VALUES (?, ?, ?, 80, 80, 80, '[]', '[]')"
	database.query_with_bindings(query, [id, peep_count, JSON.stringify(desired_destinations)])
	database.close_db()
	call_deferred('save_finished_peep')
	
func update_peep_group(id, data):
	database.open_db()
	var query = "UPDATE peep_groups SET coordinates = ?, needs_hunger = ?, needs_rest = ?, needs_toilet = ?, desired_destinations = ?, observed_animals = ?, modifiers = ? WHERE id = ?"
	var formated_coordinates = {"x": data.coordinates.x, "y": data.coordinates.y}
	database.query_with_bindings(query, [JSON.stringify(formated_coordinates), data.needs_hunger, data.needs_rest, data.needs_toilet, data.desired_destinations, data.observed_animals, data.modifiers, id] )
	database.close_db()
	call_deferred('save_finished_peep')
	
func remove_peep_group(id):
	database.open_db()
	var query = "DELETE FROM peep_groups WHERE id = ?"
	database.query_with_bindings(query, [id])
	database.close_db()
	call_deferred('save_finished_peep')


func create_peep_group_threaded(id, peep_count, desired_destinations):
	if peep_thread.is_alive():
		print('retrying save')
		await get_tree().create_timer(0.25).timeout
		create_peep_group_threaded(id, peep_count, desired_destinations)
	peep_thread.start(create_peep_group.bind(id, peep_count, desired_destinations))

func update_peep_group_threaded(id, data):
	if peep_thread.is_alive():
		print('retrying save')
		await get_tree().create_timer(0.2).timeout
		update_peep_group_threaded(id, data)
	peep_thread.start(update_peep_group.bind(id, data))

func remove_peep_group_threaded(id):
	if peep_thread.is_alive():
		print('retrying save')
		await get_tree().create_timer(0.25).timeout
		remove_peep_group_threaded(id)
	peep_thread.start(remove_peep_group.bind(id))

func update_zoo_management_threaded(data):
	return
	if data_thread.is_alive():
		print('retrying save')
		await get_tree().create_timer(0.25).timeout
		update_zoo_management_threaded(data)
	data_thread.start(update_zoo_management.bind(data))

func save_finished_peep():
	peep_thread.wait_to_finish()
	print('Game saved')
	
func save_finished_data():
	data_thread.wait_to_finish()
	print('Game saved')
	
func save_finished_construction(data):
	print('b')
	construction_save_queue.erase(data)
	#construction_thread.wait_to_finish()
	print('Game saved')

func load_game():
	database.path = db_path
	
	database.open_db()
	database.select_rows("zoo_management", "id == 0", ["reputation", "next_animal_id", "next_scenery_id", "next_enclosure_id"])
	if database.query_result:
		var data = {
			"reputation": database.query_result[0].reputation,
			"next_animal_id": database.query_result[0].next_animal_id,
			"next_scenery_id" : database.query_result[0].next_scenery_id,
			"next_enclosure_id" : database.query_result[0].next_enclosure_id,
		}
		print(data)
		SignalBus.load_zoo_management.emit(data)
	database.close_db()
	
	## Load paths
	database.open_db()
	database.select_rows("paths", "atlas_y != -2", ["pos_x", "pos_y", "atlas_y"])
	var path_cells = {}
	for cell in database.query_result:
		if cell.atlas_y not in path_cells.keys():
			path_cells[cell.atlas_y] = [Vector2i(cell.pos_x, cell.pos_y)]
		else:
			path_cells[cell.atlas_y].append(Vector2i(cell.pos_x, cell.pos_y))
	SignalBus.load_paths.emit(path_cells)
	database.close_db()
		
	return
		
	## Load terrain
	for i in [1, 2, 3, 4]:
		database.open_db()
		database.select_rows("terrain", "atlas_y == "+str(i), ["pos_x", "pos_y"])
		var terrain_cells = []
		for cell in database.query_result:
			terrain_cells.append(Vector2i(cell.pos_x, cell.pos_y))
		SignalBus.load_terrain.emit(terrain_cells, i)
		database.close_db()
		
	## Load enclosures
	database.open_db()
	var enclosure_query = database.query("SELECT * FROM enclosures")
	if database.query_result:
		for enclosure_entry in database.query_result:
			var enclosure_cells = []
			for cell in JSON.parse_string(enclosure_entry.cells):
				var new_cell = Vector2i(cell.x, cell.y)
				enclosure_cells.append(new_cell)

			var enclosure_entrance_cell = null
			if enclosure_entry.entrance_cell:
				var parsed_entrance = JSON.parse_string(enclosure_entry.entrance_cell)
				enclosure_entrance_cell = Vector2i(parsed_entrance.x, parsed_entrance.y)
			
			var enclosure_res = load(enclosure_entry.resource)
			
			SignalBus.load_enclosure.emit(enclosure_entry.id, enclosure_cells, enclosure_entrance_cell, enclosure_res)
	database.close_db()
		
	## Load animals
	database.open_db()
	var animal_query = database.query("SELECT * FROM animals")
	if database.query_result:
		for animal_entry in database.query_result:
			var parsed_coordinate = JSON.parse_string(animal_entry.coordinates)
			var animal_coordinates = Vector2(parsed_coordinate.x, parsed_coordinate.y)
			var animal_res = load(animal_entry.resource)
			
			var animal_stats = {
				"id": animal_entry.id
			}
			
			SignalBus.load_animal.emit(animal_coordinates, animal_res, animal_stats)
	database.close_db()
	
	## Load scenery
	database.open_db()
	var scenery_query = database.query("SELECT * FROM scenery")
	if database.query_result:
		for scenery_entry in database.query_result:
			var parsed_coordinate = JSON.parse_string(scenery_entry.coordinates)
			var scenery_coordinates = Vector2(parsed_coordinate.x, parsed_coordinate.y)
			var scenery_res = load(scenery_entry.resource)
			var scenery_id = scenery_entry.id
			var scenery_type = scenery_entry.scenery_type
			SignalBus.load_scenery.emit(scenery_type, scenery_id, scenery_coordinates, scenery_res)
		
	database.close_db()

	## Load peep groups
	database.open_db()
	var peep_group_query = database.query("SELECT * FROM peep_groups")
	if database.query_result:
		for peep_group_entry in database.query_result:
			var coordinates = null
			if peep_group_entry.coordinates:
				var parsed_coordinate = JSON.parse_string(peep_group_entry.coordinates)
				coordinates = Vector2(parsed_coordinate.x, parsed_coordinate.y)
			var data = {
				"id": peep_group_entry.id,
				"peep_count": peep_group_entry.peep_count,
				"coordinates": coordinates,
				"needs_hunger" : peep_group_entry.needs_hunger,
				"needs_rest" : peep_group_entry.needs_rest,
				"needs_toilet" : peep_group_entry.needs_toilet,
				"desired_destinations": JSON.parse_string(peep_group_entry.desired_destinations),
				"observed_animals": JSON.parse_string(peep_group_entry.observed_animals)
			}

			SignalBus.load_peep_group.emit(data)
	database.close_db()
	
func create_save_file():
	database.path = db_path
	database.open_db()
	
	## Create zoo management table
	## Holds a single row with all zoo management data
	var zoo_management_table = {
		"id" : { "data_type": "int", "primary_key": true, "not_null": true, "auto_increment": false },
		"reputation" : { "data_type" : "real"},
		"next_animal_id" : { "data_type" : "int"},
		"next_scenery_id" : { "data_type" : "int"},
		"next_enclosure_id" : { "data_type" : "int"}
	}
	database.create_table("zoo_management", zoo_management_table)
	database.query("INSERT INTO zoo_management (id, reputation, next_animal_id, next_scenery_id, next_enclosure_id) VALUES (0, 3, 0, 0 ,0)")
	
	## Create pathing rows
	var path_table = {
		"id" : { "data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true },
		"pos_x" : { "data_type" : "int"},
		"pos_y" : { "data_type" : "int"},
		"atlas_y" : { "data_type" : "int"}
	}
	database.create_table("paths",path_table)
	var path_cells = []
	for x in range(-45, 45):
		for y in range(-45, 45):
			var cell = {
				"pos_x" : x,
				"pos_y" : y,
				## -2 is set so that we know what path cells have not been edited
				"atlas_y" : -2
			}
			path_cells.append(cell)
	database.insert_rows("paths", path_cells)

	## Create terrain rows
	var terrain_table = {
		"id" : { "data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true },
		"pos_x" : { "data_type" : "int"},
		"pos_y" : { "data_type" : "int"},
		"atlas_y" : { "data_type" : "int"}
	}
	database.create_table("terrain",terrain_table)
	var terrain_cells = []
	for x in range(-45, 45):
		for y in range(-45, 45):
			var cell = {
				"pos_x" : x,
				"pos_y" : y,
				"atlas_y" : -1
			}
			terrain_cells.append(cell)
	database.insert_rows("terrain", terrain_cells)
	
	## Setup enclosure table
	var enclosure_table = {
		"id" : { "data_type": "int", "primary_key": true, "not_null": true },
		"cells" : { "data_type" : "String"},
		"entrance_cell" : { "data_type" : "String"},
		"resource" : { "data_type" : "String"}
	}
	database.create_table("enclosures",enclosure_table)
	
	## Setup animal table
	var animal_table = {
		"id" : { "data_type": "int", "primary_key": true, "not_null": true },
		"coordinates" : { "data_type" : "String"},
		"resource" : { "data_type" : "String"}
	}
	database.create_table("animals",animal_table)
	
	## Setup scenery table
	var scenery_table = {
		"id" : { "data_type": "int", "primary_key": true, "not_null": true },
		"scenery_type" : { "data_type": "int", "not_null": true },
		"coordinates" : { "data_type" : "String"},
		"resource" : { "data_type" : "String"}
	}
	database.create_table("scenery",scenery_table)
	
	## Setup peep group table
	var peep_group_table = {
		"id" : { "data_type": "int", "primary_key": true, "not_null": true },
		"coordinates" : { "data_type" : "String" },
		"peep_count" : { "data_type" : "int" },
		"needs_hunger": { "data_type" : "real" },
		"needs_rest":{ "data_type" : "real" },
		"needs_toilet": { "data_type" : "real" },
		"desired_destinations": {"data_type" : "String" },
		"modifiers": {"data_type" : "String" },
		"observed_animals": {"data_type" : "String" },
	}
	database.create_table("peep_groups",peep_group_table)
	
	database.close_db()
	#call_deferred('save_finished')
