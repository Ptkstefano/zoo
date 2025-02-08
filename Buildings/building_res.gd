extends Resource

class_name building_resource

@export var name : String
@export var id : IdRefs.BUILDINGS
@export var thumb : Texture2D
@export var building_menu : IdRefs.BUILDING_MENU

@export var building_scene : PackedScene

@export var size : Vector2i

@export var building_cost : float
@export var base_maintenance : float

@export var possible_directions : Array[IdRefs.DIRECTIONS] = [IdRefs.DIRECTIONS.E, IdRefs.DIRECTIONS.S]

@export var is_building_entereable : bool
@export var has_occupied_sprite : bool = false

## is_shop means building can hold products to sell
@export var is_shop : bool

@export_category("Products")
@export var building_type : IdRefs.BUILDING_TYPES
@export var product_types : Array[IdRefs.PRODUCT_TYPES]
@export var possible_products : Array[IdRefs.PRODUCTS]

@export var debug_array : Array[int]
@export var debug_str : String
