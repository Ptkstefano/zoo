extends CanvasLayer

@export var options_menu : PackedScene


func _ready() -> void:
	hide()
	%MainMenuBG.gui_input.connect(on_bg_event)
	visibility_changed.connect(on_visibility_changed)
	%BackToMenuButton.pressed.connect(on_back_to_menu)
	%OptionsMenuButton.pressed.connect(on_open_options_menu)
	%DebugMenuButton.pressed.connect(on_open_debug_menu)
	
	SignalBus.open_options_menu.connect(on_opened)
	%CloseOptionsMenu.pressed.connect(hide)
	
func on_visibility_changed():
	if visible:
		get_tree().paused = true
	else:
		get_tree().paused = false
	
func on_bg_event(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			hide()

func on_close_menu():
	hide()

func on_opened():
	if visible:
		hide()
	else:
		show()

func on_back_to_menu():
	SignalBus.save_game.emit()
	await SaveManager.finished_saving_game
	SignalBus.exiting_game_scene.emit()
	get_tree().change_scene_to_file("res://MainMenu/main_menu.tscn")
	
func on_open_options_menu():
	var menu = options_menu.instantiate()
	menu.option_menu_closed.connect(on_close_menu)
	get_parent().add_child(menu)

func on_open_debug_menu():
	SignalBus.open_box.emit(IdRefs.UI_BOXES.DEBUG_MENU)
	on_close_menu()
