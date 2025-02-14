extends Resource

class_name shelter_resource

@export var name : String
@export var thumb : Texture2D
@export var size : Vector2i
@export var shelter_scene : PackedScene
@export var z_offset : int ## Used so that buildings bigger than one tile can use a z_index from a cell other than origin
@export var interior_z_index_delta : int = 0
@export var is_entereable : bool = false
@export var possible_directions : Array[IdRefs.DIRECTIONS]
