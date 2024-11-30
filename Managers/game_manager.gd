extends Node

var playable_area_size = 90 ## Maximum and minimum value for editable cell
var game_running : bool = false

var load_game = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_game():
	game_running = true
	SignalBus.peep_navigation_changed.emit()
