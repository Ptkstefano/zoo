extends Node2D


func _ready() -> void:
	if GameManager.load_game:
		SaveManager.load_game()
	else:
		SignalBus.game_started.emit()
		
	GameManager.game_running = true
