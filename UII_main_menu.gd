extends CanvasLayer


func _ready() -> void:
	hide()
	%MainMenuBG.gui_input.connect(on_bg_event)
	visibility_changed.connect(on_visibility_changed)
	%BackToMenuButton.pressed.connect(on_back_to_menu)
	
func on_visibility_changed():
	if visible:
		get_tree().paused = true
	else:
		get_tree().paused = false
	
func on_bg_event(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			hide()

func on_back_to_menu():
	SignalBus.save_game.emit()
	await SaveManager.finished_saving_game
	SignalBus.game_stopped.emit()
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn")
	
