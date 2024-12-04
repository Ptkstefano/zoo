extends CanvasLayer

@export var product_element : PackedScene

@export var shop_modifier_element : PackedScene
@export var product_history_element : PackedScene
@export var available_products_popup : PackedScene

@export var building_id : IdRefs.BUILDINGS

var shop_node

var modifier_comments = []

var products = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ShopName.text = ContentManager.buildings[building_id].name
	shop_node.update_stats.connect(update_stats)
	%CloseButton.pressed.connect(queue_free)
	%AddProductButton.pressed.connect(open_product_menu)
	generate_stats_tab()
	generate_products_tab()
	
	%DeleteButton.pressed.connect(on_remove_building)

		
	
func on_product_cost_changed(id, new_cost):
	shop_node.update_product_price(id, new_cost)
	#products[id].product.current_price = new_cost
	
func on_product_stock_replenish(id):
	shop_node.replenish_item_stock(id)
	
	
func on_remove_building():
	shop_node.remove_building()
	queue_free()

func update_stats():
	generate_stats_tab()
	generate_products_tab()

func generate_stats_tab():
	## Sell stats list
	for child in %ProductHistoryList.get_children():
		child.queue_free()
		
	for product in shop_node.sold_units:
		var element = product_history_element.instantiate()
		element.product_name = str(product)
		element.sells = shop_node.sold_units[product]
		%ProductHistoryList.add_child(element)
	
	## Modifier list
	for child in %ShopModifierList.get_children():
		child.queue_free()
	var modifiers = shop_node.peep_modifiers as Array
	for i in 5:
		var index = modifiers.size() - i - 1
		if index < 0:
			return
		var id = modifiers[modifiers.size() - i - 1]
		if !id:
			return
		var description = ModifierManager.peep_modifiers[id].description
		var element = shop_modifier_element.instantiate()
		element.description = description
		%ShopModifierList.add_child(element)
		
		
func generate_products_tab():
	for child in %ProductList.get_children():
		child.queue_free()
		
	for id in shop_node.available_products:
		var product = shop_node.available_products[id]
		var element = product_element.instantiate()
		element.product_name = product.product.name
		element.price = product.current_price
		element.id = product.product.id
		element.auto_restock = product.auto_restock
		element.price_changed.connect(on_product_cost_changed)
		element.replenish_stock.connect(on_product_stock_replenish)
		element.remove_product.connect(on_remove_product)
		element.auto_replenish.connect(on_auto_restock_product)
		element.update_stock(product.current_stock, product.product.max_stock)
		products[product.product.id] = {'element': element, 'product': product.product}
		%ProductList.add_child(element)

func open_product_menu():
	var popup = available_products_popup.instantiate()
	#for id in ContentManager.buildings[building_id].possible_products:
	for id in [0,1,2]: ## TODO - Hard-coded this bitch so it would work on mobile
		if id not in shop_node.available_products.keys():
			popup.product_ids.append(id)
	popup.product_selected.connect(on_new_product_added)
	add_child(popup)

	
func on_new_product_added(id):
	shop_node.add_product(ContentManager.products[id])
	products[id] = ContentManager.products[id]
	generate_products_tab()

func on_remove_product(id):
	shop_node.remove_product(id)
	products.erase(id)
	generate_products_tab()

func on_auto_restock_product(id, value):
	shop_node.toggle_auto_restock(id, value)
	generate_products_tab()
