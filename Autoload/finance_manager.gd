extends Node

var current_money : float = 10000:
	set(amount):
		current_money = amount
		SignalBus.money_changed.emit(current_money)
		

func add(amount):
	current_money += amount
	
func remove(amount):
	current_money -= amount
