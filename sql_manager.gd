extends Node

var db_path = "res://Savegame/savegame.db"
var database : SQLite

var thread: Thread


func _ready() -> void:
	thread = Thread.new()
	SignalBus.save_path_changes.connect(save_path_threaded)
	SignalBus.save_terrain_changes.connect(save_terrain_threaded)
	SignalBus.save_new_enclosure.connect(create_enclosure_threaded)
	SignalBus.save_update_enclosure.connect(update_enclosure_threaded)
	database = SQLite.new()
	if !FileAccess.file_exists(db_path):
		create_save_file()
	else:
		return

	
func new_save():
	var dir_access = DirAccess.open("res://Savegame/")
	dir_access.remove(db_path)
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

func save_finished():
	thread.wait_to_finish()
	print('Game saved')

func load_game():
	database.path = db_path
	database.open_db()
	
	## Load paths
	database.select_rows("paths", "atlas_y != -1", ["pos_x", "pos_y"])
	var path_cells = []
	for cell in database.query_result:
		path_cells.append(Vector2i(cell.pos_x, cell.pos_y))
	## TODO - Adapt for atlas_y
	SignalBus.load_paths.emit(path_cells, 1)
	
	database.close_db()
	database.open_db()
	
	## Load terrain
	for i in [1, 2, 3, 4]: # <- possible terrain types:
		database.select_rows("terrain", "atlas_y == "+str(i), ["pos_x", "pos_y"])
		var terrain_cells = []
		for cell in database.query_result:
			terrain_cells.append(Vector2i(cell.pos_x, cell.pos_y))
		SignalBus.load_terrain.emit(terrain_cells, i)
	
	database.close_db()
	database.open_db()
	
	## Load enclosures
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
		
		print(enclosure_entry.id)
		print(enclosure_cells)
		print(enclosure_entrance_cell)
		print(enclosure_res)
		
		SignalBus.load_enclosure.emit(enclosure_entry.id, enclosure_cells, enclosure_entrance_cell, enclosure_res)

	
	#while database.next_row():
		## Retrieve each column value
		#var id = database.get_column("id")
		#var cells = database.get_column("cells")
		#var entrance_cell = database.get_column("entrance_cell")
		#var resource = database.get_column("resource")
#
		## Store the row as a dictionary or array
		#var enclosure_data = {
		#"id": id,
		#"cells": cells,
		#"entrance_cell": entrance_cell,
		#"resource": resource
		#}
		#enclosures.append(enclosure_data)
	
	
	database.close_db()
	
