extends PanelContainer

@export var level_star : PackedScene

var product_id
signal product_selected

func _ready() -> void:
	var product_res = ContentManager.products[product_id]
	if product_res:
		%Thumbnail.texture = product_res.thumb
		%Name.text = product_res.name
		%StockCost.text = "Stock cost: " + Helpers.money_text(product_res.stock_cost)
		%BaseSellPrice.text = "Sell price: " + Helpers.money_text(product_res.base_sell_value)
		%Maintenance.text = "Maintenance: " + Helpers.money_text(product_res.maintenance)
		%Thumbnail.texture = product_res.thumb
		%Button.pressed.connect(on_product_selected)
		for level in product_res.product_level:
			%LevelStars.add_child(level_star.instantiate())
	
func on_product_selected():
	product_selected.emit(product_id)
