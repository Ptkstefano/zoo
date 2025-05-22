extends CanvasModulate

func _ready() -> void:
	SignalBus.start_night.connect(on_start_night)
	SignalBus.start_day.connect(on_start_day)
	
	
func on_start_night():
	show()
	
func on_start_day():
	hide()
