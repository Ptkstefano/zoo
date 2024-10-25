extends Control

func _ready() -> void:
	%PlayButton.pressed.connect(on_play_button_pressed)
	%QuitButton.pressed.connect(on_quit_button_pressed)
	
func on_play_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")
	
func on_quit_button_pressed():
	get_tree().quit()
