extends Node2D

class_name Shelter

@export var shelter_name : String

signal shelter_removed

var shelter_position : Vector2
var shelter_res : shelter_resource
var used_coordinates = []
var starting_tile : Vector2
var enclosure
var rest_spots
var direction

var is_entereable : bool = false
var shelter_interior_z_index : int

var entrance_pos : Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = shelter_position
	z_index = Helpers.get_current_tile_z_index(shelter_position)
	rest_spots = $RestSpots.get_children()
	is_entereable = shelter_res.is_entereable
	if is_entereable:
		shelter_interior_z_index = z_index + shelter_res.interior_z_index_delta
		entrance_pos = $Entrance.global_position
		
	enclosure.update_navigation_region()

func remove_building():
	shelter_removed.emit(self)
