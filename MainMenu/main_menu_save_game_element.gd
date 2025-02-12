extends PanelContainer

var save_game_data

signal load_save_game

func _ready() -> void:
	if !save_game_data:
		queue_free()
		return
	gui_input.connect(on_gui_input)
	%SaveGameFileName.text = save_game_data['zoo_name']
	%DeleteSaveButton.pressed.connect(on_delete_pressed)
	
func on_gui_input(event):
	if event is InputEventScreenTouch:
		if !event.pressed:
			SaveManager.set_save_file(save_game_data['file_name'])
			load_save_game.emit()

func on_delete_pressed():
	var text = 'Confirm save game delete'
	SignalBus.open_confirmation_popup.emit(delete_save_callback, text, {})
	
func delete_save_callback(data):
	FolderDataManager.delete_save_game(save_game_data['file_name'])
	queue_free()
	
