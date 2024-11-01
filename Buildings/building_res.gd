extends Resource

class_name building_resource

@export var name : String
@export var thumb : Texture2D

@export var texture : Texture2D

@export_category("Products")
@export var building_type : NameRefs.BUILDING_TYPES
@export var product_types : Array[NameRefs.PRODUCT_TYPES]
@export var available_products : Array[product_resource]

@export_category("Visual")
@export var size : Vector2i

@export var sprite_pos : Vector2
@export var detectable_pos : Vector2

@export var sprite_pos_rotated : Vector2
@export var detectable_pos_rotated : Vector2
@export var z_offset : int ## Used so that buildings bigger than one tile can use a z_index from a cell other than origin
