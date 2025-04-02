extends CanvasLayer

var build_mode_toggled : bool = false

var contextual_bulldozer_tool : IdRefs.TOOLS

var stored_tool : IdRefs.TOOLS


func _ready() -> void:
	%BuildModeButton.toggled.connect(on_build_mode_button_toggled)
	%CloseToolButton.pressed.connect(on_deselect_tool)
	
	%FreeCamera.button_down.connect(on_free_camera_pressed.bind(true))
	%FreeCamera.button_up.connect(on_free_camera_pressed.bind(false))
	
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
	
	SignalBus.tool_selected.connect(on_tool_selected)
	SignalBus.building_placed.connect(on_building_placed)
	SignalBus.building_built.connect(on_deselect_tool)
	SignalBus.construction_menu_closed.connect(on_close_construction_menu)
	
	## Hide
	$ConstructUI.hide()
	%MainToolContainer.hide()
	%BulldozerToolsContainer.hide()
	
	## Show
	%BottomMargin.show()

func on_bulldozer_tool():
	%MainToolContainer.hide()
	%MainMargin.hide()
	%BottomMargin.hide()
	$ConstructUI.show()
	%BulldozerToolsContainer.show()
	

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
		%BottomMargin.hide()
		
		
	else:
		build_mode_toggled = false
		%MainMargin.show()
		%MainToolContainer.hide()
		%InfoBorder.hide()
		%GridLayer.hide()
		%BottomMargin.show()
	
func on_tool_selected(tool, res):
	%MainMargin.hide()
	%BottomMargin.hide()
	$ConstructUI.show()
	if tool not in [IdRefs.TOOLS.BULLDOZER_PATH, IdRefs.TOOLS.BULLDOZER_WATER, IdRefs.TOOLS.BULLDOZER_FIXTURE, IdRefs.TOOLS.BULLDOZER_SCENERY, IdRefs.TOOLS.BULLDOZER_ENCLOSURE]:
		stored_tool = tool
	if tool == IdRefs.TOOLS.PATH:
		%ContextualBulldozer.show()
		%ContextualBulldozer.text == tr('BULLDOZE_PATH')
		contextual_bulldozer_tool = IdRefs.TOOLS.BULLDOZER_PATH
	if tool == IdRefs.TOOLS.BULLDOZER_WATER:
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
