extends Node

signal tooltip

signal obstacle_changed
signal vegetation_placed

signal open_popup
signal open_box ## Emitted by UI

signal peep_navigation_changed
signal path_erased
signal path_changed

signal enclosure_removed  ## Emitted by: enclosure_scene

signal save_game
signal save_new_scenery
signal game_started

signal ui_visibility ## Emitted by: inputController
