extends Node2D

class_name Shelter

@export var shelter_name : String

var shelter_position : Vector2
var shelter_res : shelter_resource
var used_coordinates = []
var enclosure
var rest_spots

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = shelter_position
	z_index = Helpers.get_current_tile_z_index(shelter_position)
	rest_spots = $RestSpots.get_children()
