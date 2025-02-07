extends Resource

class_name decoration_resource

@export var name : String
@export var cost : float
@export var texture : Texture2D
@export var thumb : Texture2D
@export var texture_offset : Vector2
@export var size : Vector2i = Vector2i(1,1)
@export var possible_directions : Array[IdRefs.DIRECTIONS] = [0, 1]
