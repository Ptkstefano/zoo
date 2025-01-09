extends Node2D


func _ready() -> void:
	%LoadScreen.show()
	if GameManager.load_game:
		SaveManager.load_game()
	else:
		SignalBus.game_started.emit()

	AudioServer.set_bus_volume_db(0, -80)
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_property(%LoadScreen, "modulate", Color('#FFFFFF00'), 1)
	await tween.finished
	GameManager.start_game()
	AudioServer.set_bus_volume_db(0, 0)
	%LoadScreen.hide()

	
