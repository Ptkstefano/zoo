extends Resource

class_name building_resource

@export var name : String
@export var thumb : Texture2D
@export var size : Vector2i
@export var building_scene : PackedScene
@export var building_type : building.BUILDING_TYPES
@export var z_offset : int ## Used so that buildings bigger than one tile can use a z_index from a cell other than origin
