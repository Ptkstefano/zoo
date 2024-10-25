extends Node2D
class_name Shop

var product_types : Array[NameRefs.PRODUCT_TYPES]
var available_products : Array[product_resource]

var building_res : building_resource
var shop_name
var coordinates = []

var sell_positions : Array[Vector2]

var is_rotated : bool

var sold_units = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	product_types = building_res.product_types
	available_products = building_res.available_products
	$Sprites/Sprite2D.texture = building_res.texture
	if is_rotated:
		$Sprites/Sprite2D.flip_h = true
		$Sprites.position = building_res.sprite_pos_rotated
		for children in $SellPositionsRotated.get_children():
			sell_positions.append(children.global_position)
	else:
		$Sprites/Sprite2D.flip_h = false
		$Sprites.position = building_res.sprite_pos
		for children in $SellPositions.get_children():
			sell_positions.append(children.global_position)
			
	for product in available_products:
		product.current_cost = product.base_sell_value
		sold_units[product.name] = 0

func remove_building():
	get_parent().remove_building()

func buy(product : product_resource, peep_count : int):
	sold_units[product.name] += peep_count
	return
	print('Selling ' + str(peep_count) + ' ' + str(product.name))
