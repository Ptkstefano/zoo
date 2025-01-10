extends Node

signal current_month_changed

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
