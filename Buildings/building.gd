extends Node2D
class_name Building

var product_types : Array[IdRefs.PRODUCT_TYPES]
var available_products = {}

var is_shop : bool = false

var building_type : IdRefs.BUILDING_TYPES

var id : int

var building_res_id : IdRefs.BUILDINGS
var building_res : building_resource
var building_name
var coordinates = []

var sell_positions : Array[Vector2]
var enter_positions : Array[Vector2]

var peep_thoughts : Array[ThoughtManager.PEEP_THOUGHTS] = []

var direction : IdRefs.DIRECTIONS
var active_node

var number_of_peeps_inside : int = 0

var maximum_stock = 50

var shop_product_data = {}
var shop_earning_data = {'previous_month': 0, 'current_month': 0, 'lifetime': 0}
var shop_expenditure_data = {'previous_month': 0, 'current_month': 0, 'lifetime': 0}

var on_screen_notifier 

var product_load_data

var used_coordinates = []
var start_tile : Vector2

signal building_selected
signal building_removed
signal stats_updated

## Each building node requires:

	## One child for each possible direction with numbers for names (IdRefs.DIRECTIONS)
		## Each possible direction requires:
			### Sprites
			### Detectable
			### EnterPositions (with enter positions as children) - Used in entereable buildings - Leave empty if not entereable
			### SellPositions (with sell positions as children) - Used in stores that peeps don't enter - Leave empty if entereable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	building_res = ContentManager.buildings[building_res_id]
	building_type = building_res.building_type
	product_types = building_res.product_types
	z_index = Helpers.get_current_tile_z_index(global_position)

	for child in get_children():
		if child.name != str(direction):
			child.queue_free()
		else:
			active_node = child
			child.visible = true

	for children in active_node.find_child('SellPositions').get_children():
		sell_positions.append(children.global_position)
	for children in active_node.find_child('EnterPositions').get_children():
		enter_positions.append(children.global_position)
	on_screen_notifier = active_node.find_child('VisibleOnScreenNotifier2D')
	
	active_node.find_child('Detectable').parent = self
	
	if product_load_data:
		restore_data(product_load_data)
			
	TimeManager.on_pass_month.connect(on_month_pass)
	Effects.wobble(self)

## Called by popup
func remove_building():
	building_removed.emit(self)

func buy(product_id : int, peep_count : int) -> bool:
	## Called by peep_groups and returns whether purchase was succesful
	if available_products[product_id].current_stock >= peep_count:
		available_products[product_id].current_stock -= peep_count
		
		update_earn_stats(available_products[product_id].current_price * peep_count)
		update_product_stats(available_products[product_id], peep_count)
		
		FinanceManager.add(available_products[product_id].current_price * peep_count, IdRefs.PAYMENT_ADD_TYPES.PRODUCT)
		
		if on_screen_notifier.is_on_screen():
			SoundscapeManager.play_cash_register()
		
		stats_updated.emit()
		
		if available_products[product_id].current_stock < 10:
			if available_products[product_id].auto_restock == true:
				replenish_item_stock(product_id)
		return true
	else:
		return false

func add_peep_modifier(modifier : ThoughtManager.PEEP_THOUGHTS):
	if peep_thoughts.size() > 100:
		peep_thoughts.remove_at(0)
		
	peep_thoughts.append(modifier)
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
	## Update data dict
	for key in shop_product_data.keys():
		shop_product_data[key]['previous_month'] = shop_product_data[key]['current_month']
		shop_product_data[key]['current_month'] = {'value': 0, 'sell_count': 0, 'stock_expenditure': 0, 'maintenance_expenditure': 0}
		
	shop_earning_data['previous_month'] = shop_earning_data['current_month']
	shop_earning_data['current_month'] = 0
	shop_expenditure_data['previous_month'] = shop_earning_data['current_month']
	shop_expenditure_data['current_month'] = 0
	
	var product_maintenance = 0
	## Apply maintenance costs
	for key in available_products:
		product_maintenance += available_products[key].product.maintenance
		update_maintenance_stats(available_products[key])
		
	FinanceManager.remove(product_maintenance, IdRefs.PAYMENT_REMOVE_TYPES.PRODUCT_MAINTENANCE)
		
	
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

func peep_entered():
	number_of_peeps_inside += 1
	if building_res.has_occupied_sprite:
		active_node.find_child('Sprite2D').frame_coords.y = 1
	
func peep_exited():
	number_of_peeps_inside -= 1
	if building_res.has_occupied_sprite:
		if number_of_peeps_inside == 0:
			active_node.find_child('Sprite2D').frame_coords.y = 0
