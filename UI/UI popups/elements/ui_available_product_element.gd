extends PanelContainer

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
		%Button.pressed.connect(on_product_selected)
	
func on_product_selected():
	product_selected.emit(product_id)
