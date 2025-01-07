extends Resource

class_name building_resource

@export var name : String
@export var id : IdRefs.BUILDINGS
@export var thumb : Texture2D
@export var building_menu : IdRefs.BUILDING_MENU

@export var texture : Texture2D

@export_category("Products")
@export var building_type : IdRefs.BUILDING_TYPES
@export var product_types : Array[IdRefs.PRODUCT_TYPES]
@export var possible_products : Array[IdRefs.PRODUCTS]

@export var debug_array : Array[int]
@export var debug_str : String

@export var is_building_entereable : bool

@export_category("Visual")
@export var size : Vector2i

@export var sprite_pos : Vector2
@export var detectable_pos : Vector2

@export var sprite_pos_rotated : Vector2
@export var detectable_pos_rotated : Vector2
@export var z_offset : int ## Used so that buildings bigger than one tile can use a z_index from a cell other than origin

@export var building_cost : float
@export var base_maintenance : float
