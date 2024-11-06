extends CanvasLayer

@export var product_element : PackedScene

@export var shop_modifier_element : PackedScene
@export var product_history_element : PackedScene

var shop_node

var modifier_comments = []

var products = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shop_node.update_stats.connect(generate_stats_tab)
	%CloseButton.pressed.connect(queue_free)
	generate_stats_tab()
	
	#%RemoveBuildingButton.pressed.connect(on_remove_building)
	var i = 0
	for product in shop_node.available_products:
		var element = product_element.instantiate()
		element.product_name = product.name
		element.cost = product.current_cost
		element.id = i
		element.cost_changed.connect(on_product_cost_changed)
		products[i] = {'element': element, 'product': product}
		%ProductList.add_child(element)
		i += 1
		
	
func on_product_cost_changed(id, new_cost):
	products[id].product.current_cost = new_cost
	print(products[id].product.current_cost)
	
func on_remove_building():
	shop_node.remove_building()
	queue_free()

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
		
		
