extends Node2D


func _ready() -> void:
	if GameManager.load_game:
		SaveManager.load_game()
		
	GameManager.game_running = true
