extends Node

var db_path = "user://Savegame/savegame.db"
var database : SQLite

var thread: Thread


func _ready() -> void:
	setup_save_folder()
	thread = Thread.new()
	SignalBus.save_path_changes.connect(save_path_threaded)
	SignalBus.save_terrain_changes.connect(save_terrain_threaded)
	SignalBus.save_new_enclosure.connect(create_enclosure_threaded)
	SignalBus.save_update_enclosure.connect(update_enclosure_threaded)
	SignalBus.save_new_animal.connect(create_animal_threaded)
	SignalBus.save_new_scenery.connect(create_scenery_threaded)
	SignalBus.save_new_peep_group.connect(create_peep_group_threaded)
	SignalBus.save_update_peep_group.connect(update_peep_group_threaded)
	SignalBus.save_remove_peep_group.connect(remove_peep_group_threaded)
	database = SQLite.new()
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
	
func create_save_file():
	database.path = db_path
	database.open_db()
	
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
				"atlas_y" : -1
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
	call_deferred('save_finished')


func save_path(coordinates, atlas_y):
	#print(coordinates)
	database.open_db()
	var condition : String
	var i = 1
	for coord in coordinates:
		condition += str(coord)
		if i != coordinates.size():
			condition += ', '
		i += 1
	var query_string : String = "UPDATE paths SET atlas_y = 1 WHERE (pos_x, pos_y) IN (" + condition + ")"
	database.query(query_string)
	database.close_db()
	call_deferred('save_finished')

func save_terrain(coordinates, atlas_y):
	#print(coordinates)
	database.open_db()
	var condition : String
	var i = 1
	for coord in coordinates:
		condition += str(coord)
		if i != coordinates.size():
			condition += ', '
		i += 1
	var query_string : String = "UPDATE terrain SET atlas_y = "+str(atlas_y)+" WHERE (pos_x, pos_y) IN (" + condition + ")"
	database.query(query_string)
	database.close_db()
	call_deferred('save_finished')

func create_enclosure(id, cells, res_path):
	database.open_db()
	var formated_cells = []
	for cell in cells:
		formated_cells.append({"x": cell.x, "y": cell.y})

	var query = "INSERT INTO enclosures (id, cells, entrance_cell, resource) VALUES (?, ?, ?, ?)"
	database.query_with_bindings(query, [id, JSON.stringify(formated_cells), null, res_path])
	
	database.close_db()
	call_deferred('save_finished')

func update_enclosure(id, cells, entrance_cell, res_path):
	database.open_db()
	print('c')
	var formated_cells = []
	for cell in cells:
		formated_cells.append({"x": cell.x, "y": cell.y}) 
		
	var formated_entrance = {"x": entrance_cell.x, "y": entrance_cell.y}
	

	var query = "UPDATE enclosures SET cells = ?, entrance_cell = ?, resource = ? WHERE id = ?"
	database.query_with_bindings(query, [JSON.stringify(formated_cells), JSON.stringify(formated_entrance), res_path, id])
	
	print('d')
	database.close_db()
	call_deferred('save_finished')
#func save_enclosure(id, cells, entrance, res_path):


func create_animal(id, coordinates, res_path):
	database.open_db()
	var formated_coordinates = {"x": coordinates.x, "y": coordinates.y}
	var query = "INSERT INTO animals (id, coordinates, resource) VALUES (?, ?, ?)"
	database.query_with_bindings(query, [id, JSON.stringify(formated_coordinates), res_path])
	database.close_db()
	call_deferred('save_finished')

func create_scenery(scenery_type, id, coordinates, res_path):
	database.open_db()
	var formated_coordinates = {"x": coordinates.x, "y": coordinates.y}
	var query = "INSERT INTO scenery (id, scenery_type, coordinates, resource) VALUES (?, ?, ?, ?)"
	database.query_with_bindings(query, [id, scenery_type, JSON.stringify(formated_coordinates), res_path])
	database.close_db()
	call_deferred('save_finished')

func create_peep_group(id, peep_count, desired_destinations):
	database.open_db()
	var query = "INSERT INTO peep_groups (id, peep_count, desired_destinations, needs_hunger, needs_rest, needs_toilet, observed_animals, modifiers) VALUES (?, ?, ?, 80, 80, 80, '[]', '[]')"
	database.query_with_bindings(query, [id, peep_count, JSON.stringify(desired_destinations)])
	database.close_db()
	print('create peep group')
	call_deferred('save_finished')
	
func update_peep_group(id, data):
	database.open_db()
	var query = "UPDATE peep_groups SET coordinates = ?, needs_hunger = ?, needs_rest = ?, needs_toilet = ?, desired_destinations = ?, observed_animals = ?, modifiers = ? WHERE id = ?"
	var formated_coordinates = {"x": data.coordinates.x, "y": data.coordinates.y}
	database.query_with_bindings(query, [JSON.stringify(formated_coordinates), data.needs_hunger, data.needs_rest, data.needs_toilet, data.desired_destinations, data.observed_animals, data.modifiers, id] )
	database.close_db()
	print('update peep group')
	call_deferred('save_finished')
	
func remove_peep_group(id):
	database.open_db()
	var query = "DELETE FROM peep_groups WHERE id = ?"
	database.query_with_bindings(query, [id])
	database.close_db()
	call_deferred('save_finished')

func save_path_threaded(coordinates, atlas_y):
	if thread.is_alive():
		return
	thread.start(save_path.bind(coordinates, atlas_y))

func save_terrain_threaded(coordinates, atlas_y):
	if thread.is_alive():
		return
	thread.start(save_terrain.bind(coordinates, atlas_y))

func create_enclosure_threaded(id, cells, res_path):
	if thread.is_alive():
		return
	print('b')
	thread.start(create_enclosure.bind(id, cells, res_path))

func update_enclosure_threaded(id, cells, entrance, res_path):
	if thread.is_alive():
		return
	print('b')
	thread.start(update_enclosure.bind(id, cells, entrance, res_path))

func create_animal_threaded(id, coordinates, res_path):
	if thread.is_alive():
		return
	print('b')
	thread.start(create_animal.bind(id, coordinates, res_path))
	
func create_scenery_threaded(scenery_type, id, coordinates, res_path):
	if thread.is_alive():
		return
	thread.start(create_scenery.bind(scenery_type, id, coordinates, res_path))

func create_peep_group_threaded(id, peep_count, desired_destinations):
	if thread.is_alive():
		return
	thread.start(create_peep_group.bind(id, peep_count, desired_destinations))

func update_peep_group_threaded(id, data):
	if thread.is_alive():
		return
	thread.start(update_peep_group.bind(id, data))

func remove_peep_group_threaded(id):
	if thread.is_alive():
		return
	thread.start(remove_peep_group.bind(id))


func save_finished():
	thread.wait_to_finish()
	print('Game saved')

func load_game():
	database.path = db_path
	
	print('1')
	## Load paths
	database.open_db()
	database.select_rows("paths", "atlas_y != -1", ["pos_x", "pos_y"])
	var path_cells = []
	for cell in database.query_result:
		path_cells.append(Vector2i(cell.pos_x, cell.pos_y))
	## TODO - Adapt for atlas_y
	SignalBus.load_paths.emit(path_cells, 1)
	database.close_db()
		
	print('2')
	## Load terrain
	for i in [1, 2, 3, 4]:
		database.open_db()
		database.select_rows("terrain", "atlas_y == "+str(i), ["pos_x", "pos_y"])
		var terrain_cells = []
		for cell in database.query_result:
			terrain_cells.append(Vector2i(cell.pos_x, cell.pos_y))
		SignalBus.load_terrain.emit(terrain_cells, i)
		database.close_db()
		
	print('3')
	## Load enclosures
	database.open_db()
	var enclosure_query = database.query("SELECT * FROM enclosures")
	for enclosure_entry in database.query_result:
		var enclosure_cells = []
		for cell in JSON.parse_string(enclosure_entry.cells):
			print(cell)
			var new_cell = Vector2i(cell.x, cell.y)
			enclosure_cells.append(new_cell)
		
		var parsed_entrance = JSON.parse_string(enclosure_entry.entrance_cell)
		var enclosure_entrance_cell = Vector2i(parsed_entrance.x, parsed_entrance.y)
		var enclosure_res = load(enclosure_entry.resource)
		
		SignalBus.load_enclosure.emit(enclosure_entry.id, enclosure_cells, enclosure_entrance_cell, enclosure_res)
	database.close_db()
		
	print('4')
	## Load animals
	database.open_db()
	var animal_query = database.query("SELECT * FROM animals")
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
	for peep_group_entry in database.query_result:
		var parsed_coordinate = JSON.parse_string(peep_group_entry.coordinates)
		var coordinates = Vector2(parsed_coordinate.x, parsed_coordinate.y)
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
