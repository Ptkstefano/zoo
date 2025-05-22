extends Node2D

## Handles game initialization
var is_landscape : bool = false


var current_session_unix_time


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
	
	var delta_unix_time = TimeManager.get_delta_unix_time()
	
	if delta_unix_time > 0:
		SignalBus.open_box.emit(IdRefs.UI_BOXES.WELCOME)
	
	## Debug
	ResearchManager.unlock_everything()
		
	AnimalStorageManager.start()
	QuestManager.start()
	
	get_tree().get_root().size_changed.connect(resize_ui)


func generate_game_start():
	$Objects/StaffManager.spawn_staff(IdRefs.STAFF_TYPES.ZOOKEEPER_UNIQUE, null)
	$Objects/SceneryManager.generate_random_map()
	TimeManager.month_timer.start()

func resize_ui():
	## Might create mixels, need testing
	var size = get_viewport().get_visible_rect().size
	if size.x > size.y and !is_landscape:
		print('LANDSCAPE')
		get_viewport().get_window().set_content_scale_size(Vector2i(1280, 720))
		is_landscape = true
	elif size.x < size.y and is_landscape:
		print('PORTRAIT')
		get_viewport().get_window().set_content_scale_size(Vector2i(720, 1280))
		is_landscape = false
