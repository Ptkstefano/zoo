extends PanelContainer

var max_value

var month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

func _ready() -> void:
	max_value = TimeManager.default_month_time
	%TimeProgressBar.max_value = TimeManager.month_timer.wait_time
	TimeManager.on_pass_month.connect(on_month_pass)
	await get_tree().create_timer(0.25).timeout
	on_month_pass()
	
func _process(delta: float) -> void:
	%TimeProgressBar.value = max_value - TimeManager.month_timer.time_left

func on_month_pass():
	%TimeLabel.text = month_names[TimeManager.current_month - 1] +', year ' + str(TimeManager.current_year)
