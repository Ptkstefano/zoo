extends Control

signal popup_closed

func _ready() -> void:
	%CloseMenu.pressed.connect(popup_closed.emit)
	
	%AnimalButton.pressed.connect(toggle_menu.bind(%AnimalMenuContainer))
	%ActionsButton.pressed.connect(toggle_menu.bind(%ActionMenuContainer))
	%MonitorsButton.pressed.connect(toggle_menu.bind(%MonitorsContainer))
	
	#%DebugSpawnPeeps.button_down.connect(spawn_peep_group)
	#%DebugHungryPeeps.pressed.connect(hungry_peeps)
	#%DebugPassMonth.pressed.connect(pass_month)
	#%DebugToiletPeeps.pressed.connect(toilet_peeps)
	%DebugRemovePeeps.pressed.connect(remove_peeps)
	%DebugAddMoney.pressed.connect(add_money)
	%DebugSpeedTime.button_down.connect(speed_time)
	%DebugSpeedTime.button_up.connect(normal_time)
	%DebugToggleDay.pressed.connect(on_toggle_day)
	%DebugUnlockEverything.pressed.connect(on_unlock_everything)
	
	for key in ContentManager.animals.keys():
		var button_instance = Button.new()
		button_instance.pressed.connect(on_add_animal.bind(ContentManager.animals[key]))
		button_instance.text = tr(ContentManager.animals[key].tr_name)
		%AnimalList.add_child(button_instance)
		
		button_instance.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
func _process(delta: float) -> void:
	%FpsLabel.text = ("FPS: " + str(Engine.get_frames_per_second()))
		
		
func toggle_menu(menu):
	for child in %MainContainer.get_children():
		child.hide()
		
	print(menu)
	menu.show()
	
		
func on_add_animal(animal):
	AnimalStorageManager.create_animal(animal)

func spawn_peep_group():
	$"../Objects/PeepManager".instantiate_peep_group(null)
	
func remove_peeps():
	SignalBus.debug_clear_peeps.emit()
	#$"../Objects/PeepManager".debug_clear_peeps()
	
func hungry_peeps():
	$"../Objects/PeepManager".debug_hungry_peeps()

func toilet_peeps():
	$"../Objects/PeepManager".debug_toilet_peeps()

func pass_month():
	TimeManager.on_month_pass()

func add_money():
	FinanceManager.current_money += 10000
	
func speed_time():
	Engine.time_scale = 8
	
func normal_time():
	Engine.time_scale = 1

func on_toggle_day():
	GameManager.toggle_day()

func on_unlock_everything():
	ResearchManager.unlock_everything()
