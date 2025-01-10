extends Node

var current_month = 0
@onready var month_timer = $MonthTimer

signal on_pass_month

func _ready() -> void:
	month_timer.timeout.connect(on_month_pass)
	
func on_month_pass():
	current_month += 1
	month_timer.start()
	on_pass_month.emit()
