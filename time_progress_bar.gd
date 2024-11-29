extends ProgressBar

func _ready() -> void:
	max_value = TimeManager.month_timer.wait_time
	
func _process(delta: float) -> void:
	value = max_value - TimeManager.month_timer.time_left
