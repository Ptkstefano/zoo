extends Node2D
class_name Shop

var product_types : Array[IdRefs.PRODUCT_TYPES]
var available_products = {}

var building_res : building_resource
var shop_name
var coordinates = []

var sell_positions : Array[Vector2]

var peep_modifiers : Array[ModifierManager.PEEP_MODIFIERS] = []

var is_rotated : bool

var maximum_stock = 50

var sold_units = {}

signal update_stats

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	product_types = building_res.product_types
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

func remove_building():
	get_parent().remove_building()

func buy(product_id : int, peep_count : int) -> bool:
	## Called by peep_groups and returns whether purchase was succesful
	if available_products[product_id].current_stock >= peep_count:
		sold_units[product_id] += peep_count
		available_products[product_id].current_stock -= peep_count
		update_stats.emit()
		FinanceManager.add(available_products[product_id].current_price)
		return true
	else:
		return false

func add_peep_modifier(modifier : ModifierManager.PEEP_MODIFIERS):
	if peep_modifiers.size() > 100:
		peep_modifiers.remove_at(0)
		
	peep_modifiers.append(modifier)
	update_stats.emit()

func update_product_price(id, new_value):
	available_products[id].current_price = new_value
	

func replenish_item_stock(id):
	var items_to_replenish = available_products[id].product.max_stock - available_products[id].current_stock
	var replenish_cost = items_to_replenish * available_products[id].product.stock_cost
	FinanceManager.remove(replenish_cost)
	SignalBus.money_tooltip.emit(replenish_cost, false, global_position)
	available_products[id].current_stock = available_products[id].product.max_stock
	update_stats.emit()

func add_product(product : product_resource):
	available_products[product.id] = {
		'product': product,
		'current_price': product.base_sell_value,
		'current_stock': product.max_stock
		}
	if !sold_units.keys().has(product.id):
		sold_units[product.id] = 0

func remove_product(id):
	available_products.erase(id)
