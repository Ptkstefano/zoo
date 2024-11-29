extends Node2D

class_name EnclosureFenceManager

@onready var enclosure_layer_E : TileMapLayer = $E 
@onready var enclosure_layer_S : TileMapLayer = $S
@onready var enclosure_layer_W : TileMapLayer = $W
@onready var enclosure_layer_N : TileMapLayer = $N

var enclosure_tilemap

var enclosure_cells : Array[Vector2i] = []

var fence_cells : Array[Vector2i] = []
var previous_fence_cells : Array[Vector2i] = [] ## Used for figuring out what coordinates are new when updating an existing fence
var enclosure_cells_dict = {}

var fence_instances = {}

var fence_res

@export var fence_scene : PackedScene

var entrance_node : Node2D

var E_fence_cells = []
var S_fence_cells = []
var W_fence_cells = []
var N_fence_cells = []

func _ready() -> void:
	$E.visible = false
	$S.visible = false
	$W.visible = false
	$N.visible = false


func build_enclosure_fence(cells):
	## Sets cells in the invisible tilemaps
	
	E_fence_cells = []
	S_fence_cells = []
	W_fence_cells = []
	N_fence_cells = []
	
	remove_enclosure_fence()
	
	for coordinate in cells:
		
		if coordinate not in enclosure_cells:
			enclosure_cells.append(coordinate)
		
		var east_cell = Vector2i(coordinate.x + 1, coordinate.y)
		var south_cell = Vector2i(coordinate.x, coordinate.y + 1)
		var west_cell= Vector2i(coordinate.x - 1, coordinate.y)
		var north_cell= Vector2i(coordinate.x, coordinate.y - 1)
		
		## Figures out which cells are bordered by out-of-bounds cells
		if enclosure_tilemap.get_cell_atlas_coords(east_cell) == Vector2i(-1,-1):
			enclosure_layer_E.set_cell(coordinate, 0, Vector2i(0,0))
			enclosure_tilemap.set_cell(coordinate, 1, Vector2i(2,1))
			E_fence_cells.append(coordinate)
			fence_cells.append(coordinate)
		if enclosure_tilemap.get_cell_atlas_coords(north_cell) == Vector2i(-1,-1):
			enclosure_layer_N.set_cell(coordinate, 0, Vector2i(0,0))
			enclosure_tilemap.set_cell(coordinate, 1, Vector2i(1,0))
			N_fence_cells.append(coordinate)
			fence_cells.append(coordinate)
		if enclosure_tilemap.get_cell_atlas_coords(west_cell) == Vector2i(-1,-1):
			enclosure_layer_W.set_cell(coordinate, 0, Vector2i(0,0))
			enclosure_tilemap.set_cell(coordinate, 1, Vector2i(0,1))
			W_fence_cells.append(coordinate)
			fence_cells.append(coordinate)
		if enclosure_tilemap.get_cell_atlas_coords(south_cell) == Vector2i(-1,-1):
			enclosure_layer_S.set_cell(coordinate, 0, Vector2i(0,0))
			enclosure_tilemap.set_cell(coordinate, 1, Vector2i(1,2))
			S_fence_cells.append(coordinate)
			fence_cells.append(coordinate)
			
	## Set edge cells on nav_tilemap
	for cell in E_fence_cells:
		if cell in N_fence_cells:
			enclosure_tilemap.set_cell(cell, 1, Vector2i(2,0))
		if cell in S_fence_cells:
			enclosure_tilemap.set_cell(cell, 1, Vector2i(2,2))
			
	for cell in W_fence_cells:
		if cell in N_fence_cells:
			enclosure_tilemap.set_cell(cell, 1, Vector2i(0,0))
		if cell in S_fence_cells:
			enclosure_tilemap.set_cell(cell, 1, Vector2i(0,2))
			
	for cell in fence_cells:
		if cell not in previous_fence_cells:
			previous_fence_cells.append(cell)
			FinanceManager.remove(10.0, IdRefs.PAYMENT_REMOVE_TYPES.CONSTRUCTION)
			SignalBus.money_tooltip.emit(10.0, false, TileMapRef.map_to_local(cell))

	instantiate_fence_instances()


func remove_enclosure_fence():
	for enclosure_layer in get_children():
		if enclosure_layer is TileMapLayer:
			for coordinate in fence_cells:
				if enclosure_layer.get_cell_atlas_coords(coordinate) != Vector2i(-1,-1):
					enclosure_layer.set_cell(coordinate, -1, Vector2i(-1,-1))
	fence_cells.clear()
	erase_fence_instances()

func erase_fence_instances():
	for instance in $FenceInstances.get_children():
		instance.queue_free()


func instantiate_fence_instances():
	## Instantiates visual nodes for each of the used tiles in the children tilemaps
	var direction_index = 3
	for child in get_children():
		if child is TileMapLayer:
			for cell in child.get_used_cells():
				var fence_instance = fence_scene.instantiate()
				fence_instance.sprite_x = direction_index
				fence_instance.global_position = Helpers.get_global_pos_of_cell(cell)
				fence_instance.z_index = Helpers.get_current_tile_z_index(fence_instance.global_position)
				fence_instance.g_pos = Helpers.get_global_pos_of_cell(cell)
				if direction_index == 1 or direction_index == 0:
					fence_instance.z_index -= 2
				fence_instance.update_fence_instance(fence_res)
				fence_instance.name = str(cell.x) + ',' + str(cell.y)
				$FenceInstances.add_child(fence_instance)
				fence_instances[str(cell.x) + ',' + str(cell.y)] = fence_instance
		direction_index -= 1

func place_entrance(cell):
	if cell not in fence_cells:
		if Vector2(cell.x, cell.y + 1) in fence_cells:
			cell = Vector2(cell.x, cell.y + 1)
		elif Vector2(cell.x - 1, cell.y) in fence_cells:
			cell = Vector2(cell.x - 1,  cell.y)
		else:
			return
		
	## Continue only if it's not corner cell
	var is_neighbor = []
	for neighbor_cell in Helpers.get_adjacent(cell):
		if neighbor_cell in fence_cells:
			is_neighbor.append(true)
		else:
			is_neighbor.append(false)
	
	for i in is_neighbor.size():
		if is_neighbor[i - 1]:
			if is_neighbor[i]:
				#print('edge cell')
				return
				
	if is_instance_valid(entrance_node):
		entrance_node.remove_entrance()
		
	
	entrance_node = fence_instances[str(cell.x) + ',' + str(cell.y)]
	var entrance_cell = entrance_node.make_entrance()
	if entrance_cell == 0:
		return Vector2(cell.x, cell.y - 1)
	if entrance_cell == 1:
		return Vector2(cell.x - 1, cell.y)
	if entrance_cell == 2:
		return Vector2(cell.x, cell.y + 1)
	if entrance_cell == 3:
		return Vector2(cell.x + 1, cell.y)
	
func open_door():
	if is_instance_valid(entrance_node):
		entrance_node.open_door()
