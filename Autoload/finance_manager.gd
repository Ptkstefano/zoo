extends Node

signal current_month_changed

var add_text = {
	IdRefs.PAYMENT_ADD_TYPES.ENTRANCE: 'PAYMENT_ADD_ENTRANCE',
	IdRefs.PAYMENT_ADD_TYPES.FOOD_PRODUCT: 'PAYMENT_ADD_FOOD',
	IdRefs.PAYMENT_ADD_TYPES.DONATION: 'PAYMENT_ADD_DONATION',
}

var remove_text = {
	IdRefs.PAYMENT_REMOVE_TYPES.SHOP_MAINTENANCE: 'PAYMENT_REMOVE_SHOP_MAINTENANCE',
	IdRefs.PAYMENT_REMOVE_TYPES.FACILITY_MAINTENANCE: 'PAYMENT_REMOVE_FACILITY_MAINTENANCE',
	IdRefs.PAYMENT_REMOVE_TYPES.PRODUCT_MAINTENANCE: 'PAYMENT_REMOVE_PRODUCT_MAINTENANCE',
	IdRefs.PAYMENT_REMOVE_TYPES.CONSTRUCTION: 'PAYMENT_REMOVE_CONSTRUCTION',
	IdRefs.PAYMENT_REMOVE_TYPES.RESTOCK: 'PAYMENT_REMOVE_RESTOCK',
	IdRefs.PAYMENT_REMOVE_TYPES.FEED: 'PAYMENT_REMOVE_FEED',
	IdRefs.PAYMENT_REMOVE_TYPES.SALARY: 'PAYMENT_REMOVE_SALARY',
	IdRefs.PAYMENT_REMOVE_TYPES.RESEARCH_BOOST: 'PAYMENT_RESEARCH_BOOST',
}


var current_money : float = 10000:
	set(amount):
		current_money = snappedf(amount, 0.1)
		SignalBus.money_changed.emit(current_money)
		

var monthly_stats = []

var current_month_stats

func _ready() -> void:
	current_month_stats = {month = TimeManager.current_month, income = {}, expenditures = {}}
	TimeManager.on_pass_month.connect(on_pass_month)

func add(amount, type):
	current_money += amount
	if !current_month_stats['income'].keys().has(type):
		current_month_stats['income'][type] = 0
	current_month_stats['income'][type] += amount
	current_month_changed.emit()
	
func remove(amount, type : IdRefs.PAYMENT_REMOVE_TYPES):
	if !GameManager.game_running:
		return
	current_money -= amount
	if !current_month_stats['expenditures'].keys().has(type):
		current_month_stats['expenditures'][type] = 0
	current_month_stats['expenditures'][type] += amount
	current_month_changed.emit()

func is_amount_available(amount) -> bool:
	if current_money >= amount:
		return true
	else:
		return false
	

func on_pass_month():
	monthly_stats.append(current_month_stats)
	current_month_stats = {month = TimeManager.current_month, income = {}, expenditures = {}}
