extends PanelContainer

@export var level_star : PackedScene

var product_id
signal product_selected

func _ready() -> void:
	var product_res = ContentManager.products[product_id]
	if product_res:
		%Thumbnail.texture = product_res.thumb
		%Name.text = tr(product_res.tr_name)
		%StockCost.text = str(tr('UI_PRODUCT_ELEMENT_STOCK_COST')) + Helpers.money_text(product_res.stock_cost)
		%BaseSellPrice.text = str(tr('UI_PRODUCT_ELEMENT_SELL_PRICE')) + Helpers.money_text(product_res.base_sell_value)
		%Maintenance.text = str(tr('UI_PRODUCT_ELEMENT_MAINTENANCE')) + Helpers.money_text(product_res.maintenance)
		%Thumbnail.texture = product_res.thumb
		%Button.pressed.connect(on_product_selected)
		for level in product_res.product_level:
			%LevelStars.add_child(level_star.instantiate())
	
func on_product_selected():
	product_selected.emit(product_id)
