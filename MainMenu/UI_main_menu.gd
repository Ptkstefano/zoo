extends Control

func _ready() -> void:
	%ContinueButton.pressed.connect(on_continue_button_pressed)
	%StartButton.pressed.connect(on_start_new_button_pressed)
	%QuitButton.pressed.connect(on_quit_button_pressed)
	
func _process(delta: float) -> void:
	var load_progress = []
	ResourceLoader.load_threaded_get_status("res://main.tscn", load_progress)
	if load_progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get("res://main.tscn")
		get_tree().change_scene_to_packed(packed_scene)
	
func on_continue_button_pressed():
	GameManager.load_game = true
	hide_interface()
	
func on_start_new_button_pressed():
	GameManager.load_game = false
	load_main_scene()
	
	
func on_quit_button_pressed():
	get_tree().quit()

func hide_interface():
	var tween = create_tween()
	tween.tween_property(%MainContainer, 'modulate', Color('#FFFFFF00'), 1)
	await tween.finished
	load_main_scene()

func load_main_scene():
	ResourceLoader.load_threaded_request("res://main.tscn")
	
