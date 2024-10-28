extends Node2D


func _ready() -> void:
	SaveManager.load_game()
	GameManager.game_running = true
