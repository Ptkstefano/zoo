extends Node2D

## Handles game initialization

func _ready() -> void:
	%LoadScreen.show()
	AudioServer.set_bus_mute(0, true)
	if GameManager.is_load_game:
		SaveManager.load_game()
	else:
		generate_game_start()
		ResearchManager.new_game_unlocks()
	
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_property(%LoadScreen, "modulate", Color('#FFFFFF00'), 1)
	await tween.finished
	GameManager.start_game()
	AudioServer.set_bus_mute(0, false)
	SignalBus.update_enclosure_land_areas.emit()
	GlobalConfigManager.load_config()
	%LoadScreen.hide()
	SignalBus.game_started.emit()


func generate_game_start():
	$Objects/StaffManager.spawn_staff(IdRefs.STAFF_TYPES.ZOOKEEPER_UNIQUE, null)
	$Objects/SceneryManager.generate_random_map()
