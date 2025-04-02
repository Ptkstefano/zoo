extends Control

@export var save_game_element : PackedScene

func _ready() -> void:
	
	SignalBus.instantiating_main_menu.emit()
	
	#for child in %ContainerContainer.get_children():
		#if child.name != 'MainContainer':
			#child.hide()
		#else:
			#child.show()
	
	setup_save_files()
	
	#%ContinueButton.pressed.connect(on_continue_button_pressed)
	#%StartButton.pressed.connect(on_start_new_button_pressed)
	#%QuitButton.pressed.connect(on_quit_button_pressed)
	%SandboxButton.pressed.connect(on_open_container.bind('SandboxContainer'))
	%NewSandboxGame.pressed.connect(on_open_container.bind('NewSandboxZooContainer'))
	%CloseSandboxButton.pressed.connect(on_open_container.bind('MainContainer'))
	%CloseNewZooButton.pressed.connect(on_open_container.bind('MainContainer'))
	%ContinueButton.pressed.connect(setup_game_start.bind(false))
	%StartNewSandboxGame.pressed.connect(setup_game_start.bind(true))
	%ZooNameLineEdit.text_changed.connect(on_sandbox_zoo_name_changed)
	
	get_tree().paused = false
	
func _process(delta: float) -> void:
	var load_progress = []
	ResourceLoader.load_threaded_get_status("res://main.tscn", load_progress)
	if load_progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get("res://main.tscn")
		get_tree().change_scene_to_packed(packed_scene)
	
	
func setup_game_start(is_new_game : bool):
	if is_new_game:
		GameManager.is_load_game = false
		GameManager.is_new_game = true
		var zoo_name = %ZooNameLineEdit.text
		SaveManager.set_save_file(zoo_name+'.json')
		ZooManager.zoo_name = zoo_name
	else:
		GameManager.is_load_game = true
		
	start_game()
	
func start_game():
	ResourceLoader.load_threaded_request("res://main.tscn")
	
func on_quit_button_pressed():
	get_tree().quit()

func hide_interface():
	var tween = create_tween()
	tween.tween_property(%MainContainer, 'modulate', Color('#FFFFFF00'), 1)
	await tween.finished


func on_open_container(container_name):
	for child in %ContainerContainer.get_children():
		if child.name == container_name:
			child.show()
		else:
			child.hide()
		
func setup_save_files():
	if FolderDataManager.sandbox_saves.is_empty():
		%ContinueButton.disabled = true
	else:
		SaveManager.set_save_file(FolderDataManager.sandbox_saves[0]['file_name'])
	
	for child in %SandboxSaveGameList.get_children():
		child.queue_free()
	
	for sandbox_save_game in FolderDataManager.sandbox_saves:
		var save_element = save_game_element.instantiate()
		save_element.save_game_data = sandbox_save_game
		save_element.load_save_game.connect(setup_game_start.bind(false))
		%SandboxSaveGameList.add_child(save_element)

func on_sandbox_zoo_name_changed(zoo_name : String):
	if zoo_name.length() > 3:
		%StartNewSandboxGame.disabled = false
	else:
		%StartNewSandboxGame.disabled = true
