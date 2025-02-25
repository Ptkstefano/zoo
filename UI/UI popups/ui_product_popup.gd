extends CanvasLayer

var thumbnail
var product_name
var product_data
var maintenance
var stock_cost

signal replenish_product
signal remove_product
signal auto_replenish

func _ready():
	%Title.text = tr(product_name)
	#%Thumbnail.texture = thumbnail

	%Close.pressed.connect(queue_free)
	%Remove.pressed.connect(on_remove_product_pressed)
	%Replenish.pressed.connect(on_replenish_product_pressed)
	%AutoReplenishCheckbox.toggled.connect(on_replenish_product_toggled)
	
	%MaintenanceCost.text = str(maintenance)
	%StockUnitCost.text = str(stock_cost)
	
func _process(delta: float) -> void:
	%PreviousUnitsSold.text = str(product_data['previous_month'].sell_count)
	%PreviousRevenue.text = Helpers.money_text(product_data['previous_month'].value)
	%PreviousExpenditures.text = Helpers.money_text(product_data['previous_month'].maintenance_expenditure + product_data['previous_month'].stock_expenditure)
	%PreviousTotal.text = Helpers.money_text(product_data['previous_month'].value - (product_data['previous_month'].maintenance_expenditure + product_data['previous_month'].stock_expenditure))
	
	%CurrentUnitsSold.text = str(product_data['current_month'].sell_count)
	%CurrentRevenue.text = Helpers.money_text(product_data['current_month'].value)
	%CurrentExpenditures.text = Helpers.money_text(product_data['current_month'].maintenance_expenditure + product_data['current_month'].stock_expenditure)
	%CurrentTotal.text = Helpers.money_text(product_data['current_month'].value - (product_data['current_month'].maintenance_expenditure + product_data['current_month'].stock_expenditure))
	
	%LifetimeUnitsSold.text = str(product_data['lifetime'].sell_count)
	%LifetimeRevenue.text = Helpers.money_text(product_data['lifetime'].value)
	%LifetimeExpenditures.text = Helpers.money_text(product_data['lifetime'].maintenance_expenditure + product_data['lifetime'].stock_expenditure)
	%LifetimeTotal.text = Helpers.money_text(product_data['lifetime'].value - (product_data['lifetime'].maintenance_expenditure + product_data['lifetime'].stock_expenditure))

func on_remove_product_pressed():
	remove_product.emit()
	queue_free()
	
func on_replenish_product_pressed():
	replenish_product.emit()
	
func on_replenish_product_toggled(value):
	auto_replenish.emit(value)
