extends Node2D


func _ready() -> void:
	if GameManager.load_game:
		SqlManager.load_game()
	else:
		SqlManager.new_save()
		
	GameManager.game_running = true
