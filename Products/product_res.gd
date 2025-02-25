extends Resource

class_name product_resource

@export var id : IdRefs.PRODUCTS
@export var type : IdRefs.PRODUCT_TYPES
@export var tr_name : String
@export var thumb : Texture2D

@export var base_sell_value : float  ## Base price when building is plopped down
@export var perceived_value : float  ## Base price as perceived by peeps

@export_range (1, 3) var product_level : int ## Peep groups have a minimum level requirement for a product

@export var stock_cost : float ## Price zoo pays per unit
@export var max_stock : int
@export var maintenance : float ## Price added to shop maintenance to keep this product
