extends CanvasLayer

var build_mode_toggled : bool = false

var contextual_bulldozer_tool : IdRefs.TOOLS

var stored_tool : IdRefs.TOOLS

var star_instances

@export var level_star : Texture
@export var level_star_half : Texture

@export var animal_carousel_element : PackedScene


func _ready() -> void:
	%BuildModeButton.toggled.connect(on_build_mode_button_toggled)
	%CloseToolButton.pressed.connect(on_deselect_tool)
	
	%FreeCamera.button_down.connect(on_free_camera_pressed.bind(true))
	%FreeCamera.button_up.connect(on_free_camera_pressed.bind(false))
	
	%BottomPanelButton.pressed.connect(SignalBus.open_box.emit.bind(IdRefs.UI_BOXES.MANAGEMENT))
	%OptionsButton.pressed.connect(SignalBus.open_options_menu.emit)
	
	%AnimalModeButton.pressed.connect(toggle_animal_mode)
	%CloseAnimalModeButton.pressed.connect(on_build_mode_button_toggled.bind(false))
	
	%EnclosureMenuButton.pressed.connect(on_open_construction_menu.bind(IdRefs.CONSTRUCTION_MENUS.ENCLOSURE))
	%PathMenuButton.pressed.connect(on_open_construction_menu.bind(IdRefs.CONSTRUCTION_MENUS.PATH))
	%BuildingMenuButton.pressed.connect(on_open_construction_menu.bind(IdRefs.CONSTRUCTION_MENUS.BUILDING))
	%SceneryMenuButton.pressed.connect(on_open_construction_menu.bind(IdRefs.CONSTRUCTION_MENUS.SCENERY))
	%TerrainMenuButton.pressed.connect(on_open_construction_menu.bind(IdRefs.CONSTRUCTION_MENUS.TERRAIN))
	%LakeMenuButton.pressed.connect(on_open_construction_menu.bind(IdRefs.CONSTRUCTION_MENUS.LAKE))
	
	%SceneryBulldozer.pressed.connect(on_bulldozer_tool_selected.bind(IdRefs.TOOLS.BULLDOZER_SCENERY))
	%EnclosureBulldozer.pressed.connect(on_bulldozer_tool_selected.bind(IdRefs.TOOLS.BULLDOZER_ENCLOSURE))
	%PathBulldozer.pressed.connect(on_bulldozer_tool_selected.bind(IdRefs.TOOLS.BULLDOZER_PATH))
	%FixtureBulldozer.pressed.connect(on_bulldozer_tool_selected.bind(IdRefs.TOOLS.BULLDOZER_FIXTURE))
	%LakeBulldozer.pressed.connect(on_bulldozer_tool_selected.bind(IdRefs.TOOLS.BULLDOZER_WATER))
	
	%BulldozerMenuButton.pressed.connect(on_bulldozer_tool)
	
	%ContextualBulldozer.button_down.connect(on_contextual_bulldozer.bind(true))
	%ContextualBulldozer.button_up.connect(on_contextual_bulldozer.bind(false))
	
	%RotateButton.pressed.connect(SignalBus.rotate_building.emit)
	%BuildButton.pressed.connect(SignalBus.building_built.emit)
	
	%WorldMapButton.pressed.connect(SignalBus.open_box.emit.bind(IdRefs.UI_BOXES.WORLD_MAP))
	%ExpeditionsButton.pressed.connect(SignalBus.open_box.emit.bind(IdRefs.UI_BOXES.WORLD_MAP))
	%AnimalStorageButton.pressed.connect(SignalBus.open_box.emit.bind(IdRefs.UI_BOXES.ANIMAL_STORAGE))
	
	SignalBus.tool_selected.connect(on_tool_selected)
	SignalBus.building_placed.connect(on_building_placed)
	SignalBus.building_built.connect(on_deselect_tool)
	SignalBus.construction_menu_closed.connect(on_close_construction_menu)
	#SignalBus.animal_placed.connect(on_deselect_tool.unbind(1))
	#SignalBus.animal_placed.connect(on_build_mode_button_toggled.unbind(1).bind(false))
	SignalBus.animal_placed.connect(on_animal_placed)
	SignalBus.money_changed.connect(on_money_changed)
	
	ZooManager.zoo_reputation_updated.connect(on_reputation_update)
	ZooManager.peep_count_updated.connect(on_peep_count_update)
	star_instances = %ReputationStars.get_children()
	on_reputation_update(ZooManager.reputation)
	
	TimeManager.on_pass_month.connect(on_month_pass)
	on_month_pass()
	
	on_money_changed(FinanceManager.current_money)
	
	## Hide
	$ConstructUI.hide()
	%MainToolContainer.hide()
	%BulldozerToolsContainer.hide()
	%AnimalModeMargin.hide()
	
	## Show
	%BottomMargin.show()

func _process(delta: float) -> void:
	%TimeProgressBar.value = TimeManager.get_timer_progress()

func on_peep_count_update(count):
	%PeepCountLabel.text = str(count)

func on_reputation_update(reputation):
	var rounded = round(reputation * 2) * 0.5
	
	var full_stars = int(floor(rounded))
	var has_half_star = (rounded - full_stars) > 0

	# Step 3: Build the star string
	for i in range(5):
		if i + 1 <= full_stars:
			star_instances[i].texture = level_star
		else:
			if i == full_stars and has_half_star:
				star_instances[i].texture = level_star_half
			else:
				star_instances[i].texture = null
	

func on_bulldozer_tool():
	%MainToolContainer.hide()
	%MainMargin.hide()
	%BottomMargin.hide()
	$ConstructUI.show()
	%BulldozerToolsContainer.show()
	%ContextualBulldozer.hide()
	

func on_open_construction_menu(menu : IdRefs.CONSTRUCTION_MENUS):
	%MainToolContainer.hide()
	SignalBus.open_construction_menu.emit(menu)
	
	
func on_close_construction_menu():
	%MainToolContainer.show()

func on_building_placed():
	%BuildingButtonsContainer.show()

func on_free_camera_pressed(pressed):
	SignalBus.free_camera.emit(pressed)

func on_build_mode_button_toggled(value):
	if value:
		build_mode_toggled = true
		%MainMargin.show()
		%MainToolContainer.show()
		%InfoBorder.show()
		%GridLayer.show()
		%AnimalModeMargin.hide()
		%BottomMargin.hide()
		
		
	else:
		build_mode_toggled = false
		%MainMargin.show()
		%MainToolContainer.hide()
		%InfoBorder.hide()
		%GridLayer.hide()
		%AnimalModeMargin.hide()
		%BottomMargin.show()
	
func on_tool_selected(tool, res):
	if tool == IdRefs.TOOLS.NONE:
		return
	
	if tool in [IdRefs.TOOLS.ANIMAL]:
		return
	%MainMargin.hide()
	%BottomMargin.hide()
	$ConstructUI.show()
	if tool not in [IdRefs.TOOLS.BULLDOZER_PATH, IdRefs.TOOLS.BULLDOZER_WATER, IdRefs.TOOLS.BULLDOZER_FIXTURE, IdRefs.TOOLS.BULLDOZER_SCENERY, IdRefs.TOOLS.BULLDOZER_ENCLOSURE]:
		stored_tool = tool
	if tool == IdRefs.TOOLS.PATH:
		%ContextualBulldozer.show()
		%ContextualBulldozer.text == tr('BULLDOZE_PATH')
		contextual_bulldozer_tool = IdRefs.TOOLS.BULLDOZER_PATH
	if tool == IdRefs.TOOLS.WATER:
		%ContextualBulldozer.show()
		%ContextualBulldozer.text == tr('BULLDOZE_WATER')
		contextual_bulldozer_tool = IdRefs.TOOLS.BULLDOZER_WATER
	if tool in [IdRefs.TOOLS.FIXTURE, IdRefs.TOOLS.DECORATION]:
		%ContextualBulldozer.show()
		%ContextualBulldozer.text == tr('BULLDOZE_FIXTURE')
		contextual_bulldozer_tool = IdRefs.TOOLS.BULLDOZER_FIXTURE
	if tool in [IdRefs.TOOLS.TREE, IdRefs.TOOLS.VEGETATION, IdRefs.TOOLS.ROCK, IdRefs.TOOLS]:
		%ContextualBulldozer.show()
		%ContextualBulldozer.text == tr('BULLDOZE_SCENERY')
		contextual_bulldozer_tool = IdRefs.TOOLS.BULLDOZER_SCENERY
	if tool == IdRefs.TOOLS.ENCLOSURE:
		%ContextualBulldozer.show()
		%ContextualBulldozer.text == tr('BULLDOZE_ENCLOSURE')
		contextual_bulldozer_tool = IdRefs.TOOLS.BULLDOZER_ENCLOSURE
	if tool == IdRefs.TOOLS.TERRAIN:
		%ContextualBulldozer.hide()
	if tool == IdRefs.TOOLS.BUILDING:
		%ContextualBulldozer.hide()
	if tool == IdRefs.TOOLS.ANIMAL:
		%ContextualBulldozer.hide()

func add_element_to_menu(menu, element):
	return

func on_deselect_tool():
	$ConstructUI.hide()
	%BuildingButtonsContainer.hide()
	%BulldozerToolsContainer.hide()
	on_build_mode_button_toggled(true)
	SignalBus.tool_deselected.emit()
	stored_tool = IdRefs.TOOLS.NONE

func on_stop_construction():
	%MainMargin.show()
	%BottomMargin.show()
	%MainToolContainer.hide()

func on_bulldozer_tool_selected(tool):
	SignalBus.tool_selected.emit(tool, null)

func on_contextual_bulldozer(pressed):
	if pressed:
		SignalBus.tool_selected.emit(contextual_bulldozer_tool, null)
	else:
		SignalBus.tool_selected.emit(stored_tool, null)

func on_money_changed(value):
	%MoneyLabel.text = Helpers.money_text(value)

func on_month_pass():
	var months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
	%TimeLabel.text = tr('YEAR') + ' ' + str(TimeManager.current_year) + ', ' + tr('MONTH') + ' ' + tr(months[TimeManager.current_month - 1])

func toggle_animal_mode():
	%ConstructUI.hide()
	%BottomMargin.hide()
	%MainMargin.hide()
	%AnimalModeMargin.show()
	update_animal_carousel()

func on_animal_placed(id):
	SignalBus.tool_selected.emit(IdRefs.TOOLS.NONE, null)
	for child in %AnimalCarouselList.get_children():
		if child.stored_animal.id == id:
			child.queue_free()
	
	update_animal_carousel()

func on_animal_carousel_element_selected(id):
	for child in %AnimalCarouselList.get_children():
		if child.stored_animal.id != id:
			child.deselect()
	

func update_animal_carousel():
	for child in %AnimalCarouselList.get_children():
		child.queue_free()
		
	for species_key in AnimalStorageManager.stored_animals.keys():
		for animal in AnimalStorageManager.stored_animals[species_key]:
			var element = animal_carousel_element.instantiate()
			element.stored_animal = animal
			element.place_animal.connect(place_animal)
			element.element_selected.connect(on_animal_carousel_element_selected)
			#element.release_animal.connect(release_animal)
			%AnimalCarouselList.add_child(element)

func place_animal(animal):
	SignalBus.tool_selected.emit(IdRefs.TOOLS.ANIMAL, animal)
