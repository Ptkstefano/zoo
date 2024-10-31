extends Control

func _ready() -> void:
	%ContinueButton.pressed.connect(on_continue_button_pressed)
	%StartButton.pressed.connect(on_start_new_button_pressed)
	%QuitButton.pressed.connect(on_quit_button_pressed)
	
func on_continue_button_pressed():
	GameManager.load_game = true
	get_tree().change_scene_to_file("res://main.tscn")
	
func on_start_new_button_pressed():
	GameManager.load_game = false
	get_tree().change_scene_to_file("res://main.tscn")
	
func on_quit_button_pressed():
	get_tree().quit()
