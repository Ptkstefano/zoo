extends Node

var current_month = 0
@onready var month_timer = $MonthTimer

func _ready() -> void:
	month_timer.timeout.connect(on_month_pass)
	
func on_month_pass():
	current_month += 1
	month_timer.start()
	SignalBus.pass_month.emit()
