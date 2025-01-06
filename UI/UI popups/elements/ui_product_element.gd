extends PanelContainer

var product_name
var price
var id
var maintenance
var stock_cost
var auto_restock : bool = true
var product_level : int
var thumbnail_texture : Texture2D

var product_data

@export var level_star : PackedScene

@export var product_popup : PackedScene

signal price_changed
signal replenish_stock
signal remove_product
signal auto_replenish

func _ready() -> void:
	%Minus.pressed.connect(on_value_change.bind(-0.1))
	%Plus.pressed.connect(on_value_change.bind(0.1))
	#%ReplenishButton.pressed.connect(on_replenish_stock)
	%Price.text = "$" + str(price).pad_decimals(2)
	## TODO - Grab name
	%ProductName.text = str(product_name)
	#%Remove.pressed.connect(on_remove_product)
	#%AutoReplenishCheckbox.button_pressed = auto_restock
	#%AutoReplenishCheckbox.toggled.connect(on_replenish_toggled)
	%Thumbnail.texture = thumbnail_texture
	
	%ProductButton.pressed.connect(on_open_product_popup)
	
	for level in product_level:
		var star_texture = level_star.instantiate()
		%LevelStars.add_child(star_texture)
	
func on_value_change(value):
	price = clampf(price + value, 0, 50)
	price_changed.emit(id, price)
	%Price.text = "$" + str(price).pad_decimals(2)

func update_stock(current_stock, maximum):
	%Stock.text = str(int(current_stock)) + ' / ' + str(maximum)
	
func on_replenish_stock():
	replenish_stock.emit(id)

func on_remove_product():
	remove_product.emit(id)

func on_replenish_toggled(value):
	auto_replenish.emit(id, value)

func on_open_product_popup():
	var popup_instance = product_popup.instantiate()
	popup_instance.product_data = product_data
	popup_instance.thumbnail = thumbnail_texture
	popup_instance.product_name = product_name
	popup_instance.maintenance = maintenance
	popup_instance.stock_cost = stock_cost
	popup_instance.replenish_product.connect(on_replenish_stock)
	popup_instance.remove_product.connect(on_remove_product)
	popup_instance.auto_replenish.connect(on_replenish_toggled)
	
	add_child(popup_instance)
