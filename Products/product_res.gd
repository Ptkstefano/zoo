extends Resource

class_name product_resource

@export var name : IdRefs.PRODUCTS
@export var type : IdRefs.PRODUCT_TYPES
@export var thumb : Texture2D

@export var sell_cost : float
@export var base_sell_value : float
@export var perceived_value : float

var current_cost = sell_cost
