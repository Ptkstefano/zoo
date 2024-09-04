extends Node2D

class_name FenceManager

@onready var fence_layer_E : TileMapLayer = $E 
@onready var fence_layer_S : TileMapLayer = $S
@onready var fence_layer_W : TileMapLayer = $W
@onready var fence_layer_N : TileMapLayer = $N

var area_tilemap

var fence_cells = []

@export var fence_scene : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$E.visible = false
	$S.visible = false
	$W.visible = false
	$N.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func build_fence(area_cells, fence_res):
	for coordinate in area_cells:
		var east_cell = Vector2i(coordinate.x + 1, coordinate.y)
		var south_cell = Vector2i(coordinate.x, coordinate.y + 1)
		var west_cell= Vector2i(coordinate.x - 1, coordinate.y)
		var north_cell= Vector2i(coordinate.x, coordinate.y - 1)
		
		if area_tilemap.get_cell_atlas_coords(east_cell) == Vector2i(-1,-1):
			fence_layer_E.set_cell(coordinate, 0, Vector2i(0,1))
			fence_cells.append(coordinate)
		if area_tilemap.get_cell_atlas_coords(south_cell) == Vector2i(-1,-1):
			fence_layer_S.set_cell(coordinate, 0, Vector2i(1,1))
			fence_cells.append(coordinate)
		if area_tilemap.get_cell_atlas_coords(west_cell) == Vector2i(-1,-1):
			fence_layer_W.set_cell(coordinate, 0, Vector2i(3,1))
			fence_cells.append(coordinate)
		if area_tilemap.get_cell_atlas_coords(north_cell) == Vector2i(-1,-1):
			fence_layer_N.set_cell(coordinate, 0, Vector2i(2,1))
			fence_cells.append(coordinate)
			
	instantiate_fence(fence_res)
			

func remove_fence():
	for fence_layer in get_children():
		if fence_layer is TileMapLayer:
			for coordinate in fence_cells:
				if fence_layer.get_cell_atlas_coords(coordinate) != Vector2i(-1,-1):
					fence_layer.set_cell(coordinate, -1, Vector2i(-1,-1))
	fence_cells.clear()
	for instance in $FenceInstances.get_children():
		instance.queue_free()
		

func instantiate_fence(fence_res):
	var direction_index = 3
	for child in get_children():
		if child is TileMapLayer:
			for cell in child.get_used_cells():
				var fence_instance = fence_scene.instantiate()
				fence_instance.sprite_x = direction_index
				fence_instance.global_position = Helpers.get_global_pos_of_cell(cell)
				fence_instance.z_index = Helpers.get_current_tile_z_index(fence_instance.global_position)
				if direction_index == 1 or direction_index == 0:
					fence_instance.z_index -= 2
				fence_instance.update_fence_instance(fence_res)
				$FenceInstances.add_child(fence_instance)
		direction_index -= 1
