extends Resource

class_name shelter_resource

@export var name : String
@export var thumb : Texture2D
@export var size : Vector2i
@export var shelter_scene : PackedScene
@export var z_offset : int ## Used so that buildings bigger than one tile can use a z_index from a cell other than origin
