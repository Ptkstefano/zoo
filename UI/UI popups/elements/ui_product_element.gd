extends PanelContainer

var product_name
var price
var id
var auto_restock

signal price_changed
signal replenish_stock
signal remove_product
signal auto_replenish

func _ready() -> void:
	%Minus.pressed.connect(on_value_change.bind(-0.1))
	%Plus.pressed.connect(on_value_change.bind(0.1))
	%ReplenishButton.pressed.connect(on_replenish_stock)
	%Price.text = "$" + str(price).pad_decimals(2)
	## TODO - Grab name
	%ProductName.text = str(product_name)
	%Remove.pressed.connect(on_remove_product)
	%AutoReplenishCheckbox.button_pressed = auto_restock
	%AutoReplenishCheckbox.toggled.connect(on_replenish_toggled)
	
func on_value_change(value):
	price = clampf(price + value, 0, 50)
	price_changed.emit(id, price)
	%Price.text = "$" + str(price).pad_decimals(2)

func update_stock(current_stock, maximum):
	%Stock.text = str(current_stock) + ' / ' + str(maximum)
	
func on_replenish_stock():
	replenish_stock.emit(id)

func on_remove_product():
	remove_product.emit(id)

func on_replenish_toggled(value):
	print('TOGGLED')
	auto_replenish.emit(id, value)
