extends Node

var delta_unix_time = 0


var current_month : int = 1:
	set(value):
		if value > 12:
			current_month = 1
			pass_year()
		else:
			current_month = value
			
var current_year : int = 0

@onready var month_timer = $MonthTimer

var default_month_time : int = 150

signal on_pass_month

var is_first_month_in_session : bool = true

func _ready() -> void:
	month_timer.timeout.connect(on_month_pass)
	
func on_month_pass():
	current_month += 1
	on_pass_month.emit()
	if is_first_month_in_session:
		$MonthTimer.wait_time = default_month_time
		is_first_month_in_session = false
	
	month_timer.start()

func pass_year():
	current_year += 1

func get_timer_progress():
	return default_month_time - month_timer.time_left
	
func get_timer_time_left():
	return month_timer.time_left

func set_timer_time_left(time):
	month_timer.start(time)

func update_unix_time(previous_unix_time):
	var current_unix_time = Time.get_unix_time_from_system()
	delta_unix_time = int(current_unix_time - previous_unix_time)

func get_delta_unix_time():
	return delta_unix_time
