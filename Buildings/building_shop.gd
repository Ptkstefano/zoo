extends Node2D
class_name Shop

var product_types : Array[IdRefs.PRODUCT_TYPES]
var available_products = {}


var building_res_id : IdRefs.BUILDINGS
var building_res : building_resource
var shop_name
var coordinates = []

var sell_positions : Array[Vector2]
var enter_positions : Array[Vector2]

var peep_modifiers : Array[ModifierManager.PEEP_MODIFIERS] = []

var is_rotated : bool

var maximum_stock = 50

var shop_product_data = {}
var shop_earning_data = {'previous_month': 0, 'current_month': 0, 'lifetime': 0}
var shop_expenditure_data = {'previous_month': 0, 'current_month': 0, 'lifetime': 0}

signal stats_updated

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	building_res = ContentManager.buildings[building_res_id]
	
	product_types = building_res.product_types
	$Sprites/Sprite2D.texture = building_res.texture

	if is_rotated:
		$Sprites/Sprite2D.flip_h = true
		$Sprites.position = building_res.sprite_pos_rotated
		for children in $SellPositionsRotated.get_children():
			sell_positions.append(children.global_position)
		for children in $EnterPositionsRotated.get_children():
			enter_positions.append(children.global_position)
			
	else:
		$Sprites/Sprite2D.flip_h = false
		$Sprites.position = building_res.sprite_pos
		for children in $SellPositions.get_children():
			sell_positions.append(children.global_position)
		for children in $EnterPositions.get_children():
			enter_positions.append(children.global_position)
			
	SignalBus.pass_month.connect(on_month_pass)
	Effects.wobble(self)

func remove_building():
	get_parent().remove_building()

func buy(product_id : int, peep_count : int) -> bool:
	## Called by peep_groups and returns whether purchase was succesful
	if available_products[product_id].current_stock >= peep_count:
		available_products[product_id].current_stock -= peep_count
		
		update_earn_stats(available_products[product_id].current_price * peep_count)
		update_product_stats(available_products[product_id], peep_count)
		
		FinanceManager.add(available_products[product_id].current_price * peep_count, IdRefs.PAYMENT_ADD_TYPES.PRODUCT)
		
		stats_updated.emit()
		
		if available_products[product_id].current_stock < 10:
			if available_products[product_id].auto_restock == true:
				replenish_item_stock(product_id)
		return true
	else:
		return false

func add_peep_modifier(modifier : ModifierManager.PEEP_MODIFIERS):
	if peep_modifiers.size() > 100:
		peep_modifiers.remove_at(0)
		
	peep_modifiers.append(modifier)
	stats_updated.emit()

func update_product_price(id, new_value):
	available_products[id].current_price = new_value
	

func replenish_item_stock(id):
	var items_to_replenish = available_products[id].product.max_stock - available_products[id].current_stock
	var replenish_cost = items_to_replenish * available_products[id].product.stock_cost
	update_stock_stats(id, replenish_cost)
	FinanceManager.remove(replenish_cost, IdRefs.PAYMENT_REMOVE_TYPES.RESTOCK)
	SignalBus.money_tooltip.emit(replenish_cost, false, global_position)
	available_products[id].current_stock = available_products[id].product.max_stock
	stats_updated.emit()

func add_product(product : product_resource):
	available_products[product.id] = {
		'product': product,
		'current_price': product.base_sell_value,
		'current_stock': 0,
		'auto_restock': true,
		}
	if product.id not in shop_product_data.keys():
		shop_product_data[product.id] = {
			'previous_month': {'value': 0, 'sell_count': 0, 'stock_expenditure': 0, 'maintenance_expenditure': 0},
		 'current_month': {'value': 0, 'sell_count': 0, 'stock_expenditure': 0, 'maintenance_expenditure': 0},
		 'lifetime': {'value': 0, 'sell_count': 0, 'stock_expenditure': 0, 'maintenance_expenditure': 0}
		}
	replenish_item_stock(product.id)
		
func remove_product(id):
	available_products.erase(id)
	shop_product_data.erase(id)

func toggle_auto_restock(id, value):
	available_products[id].auto_restock = value

func restore_data(data):
	if data.has('products'):
		for product in data['products']:
			var product_id = int( data['products'][product]['product_id'])
			available_products[product_id] = {
				'product': ContentManager.products[product_id],
				'current_price':  data['products'][product]['current_price'],
				'current_stock':  data['products'][product]['current_stock'],
				'auto_restock':  data['products'][product]['auto_restock'],
			}
	if data.has('shop_stats'):
		shop_product_data = data['shop_stats'].get('shop_product_stats', {})
		shop_earning_data = data['shop_stats'].get('shop_earning_stats', {'previous_month': 0, 'current_month': 0, 'lifetime': 0})
		shop_expenditure_data = data['shop_stats'].get('shop_expenditure_stats', {'previous_month': 0, 'current_month': 0, 'lifetime': 0})
	

func on_month_pass():
	var product_maintenance = 0
	## Apply maintenance costs
	for key in available_products:
		product_maintenance += available_products[key].product.maintenance
		update_maintenance_stats(available_products[key])
		
	FinanceManager.remove(product_maintenance, IdRefs.PAYMENT_REMOVE_TYPES.PRODUCT_MAINTENANCE)
		
	## Update data dict
	for key in shop_product_data.keys():
		shop_product_data[key]['previous_month'] = shop_product_data[key]['current_month']
		shop_product_data[key]['current_month'] = {'value': 0, 'sell_count': 0, 'stock_expenditure': 0, 'maintenance_expenditure': 0}
		
	shop_earning_data['previous_month'] = shop_earning_data['current_month']
	shop_earning_data['current_month'] = 0
	shop_expenditure_data['previous_month'] = shop_earning_data['current_month']
	shop_expenditure_data['current_month'] = 0
		

	
	
func update_earn_stats(value):
	shop_earning_data['current_month'] += value
	shop_earning_data['lifetime'] += value
		
func update_product_stats(product, count):
	shop_product_data[product.product.id]['current_month']['value'] += product.current_price * count
	shop_product_data[product.product.id]['lifetime']['value'] += product.current_price * count
	shop_product_data[product.product.id]['current_month']['sell_count'] += count
	shop_product_data[product.product.id]['lifetime']['sell_count'] += count

func update_maintenance_stats(product):
	shop_product_data[product.product.id]['current_month']['maintenance_expenditure'] += product.product.maintenance
	shop_product_data[product.product.id]['lifetime']['maintenance_expenditure'] += product.product.maintenance
	shop_expenditure_data['current_month'] += product.product.maintenance
	shop_expenditure_data['lifetime'] += product.product.maintenance
	
func update_stock_stats(product_id, replenish_cost):
	shop_product_data[product_id]['current_month']['stock_expenditure'] += replenish_cost
	shop_product_data[product_id]['lifetime']['stock_expenditure'] += replenish_cost
	shop_expenditure_data['current_month'] += replenish_cost
	shop_expenditure_data['lifetime'] += replenish_cost
