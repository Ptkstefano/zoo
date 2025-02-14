extends Node

var playable_area_size = 90 ## Maximum and minimum value for editable cell
var game_running : bool = false

var is_new_game : bool = false
var is_load_game : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.exiting_game_scene.connect(on_stop_game)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_game():
	game_running = true
	SignalBus.peep_navigation_changed.emit()
	MusicManager.start()

func on_stop_game():
	is_new_game= false
	is_load_game = false
	game_running = false
