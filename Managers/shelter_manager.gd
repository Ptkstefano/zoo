extends Node2D

class_name ShelterManager

@export var available_shelters : Array[shelter_resource]
@export var ui_shelter_element : PackedScene

var coordinates_used_by_shelters = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func build_shelter(shelter_res, starting_tile, direction):
	if !shelter_res:
		print('No shelter resource found')
		return
	var enclosure = TileMapRef.get_enclosure_by_cell(starting_tile)
	print(starting_tile)
	if !enclosure:
		print('No enclosure for shelter')
		return
	var new_shelter = shelter_res.shelter_scene.instantiate()
	new_shelter.shelter_position = TileMapRef.map_to_local(starting_tile)
	new_shelter.shelter_res = shelter_res
	new_shelter.starting_tile = starting_tile
	new_shelter.direction = direction
	new_shelter.shelter_removed.connect(on_shelter_removed)
	new_shelter.enclosure = enclosure
	add_child(new_shelter)
	coordinates_used_by_shelters.append(Helpers.get_building_cells(shelter_res.size, starting_tile, direction).duplicate())
	enclosure.add_shelter(new_shelter)
	
	
func on_shelter_removed(shelter_node):
	for coordinate in shelter_node.used_coordinates:
		coordinates_used_by_shelters.erase(coordinate)
		
	shelter_node.enclosure.remove_shelter(shelter_node)
	shelter_node.queue_free()

func on_shelter_selected(shelter_node):
	$"../../PopupManager".open_shelter_popup(shelter_node)
	
