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

## Save-game signals emitted by manager nodes
signal save_path_changes
signal save_terrain_changes
signal save_new_enclosure
signal save_update_enclosure

## Load-game signals sent by sqlmanager to manager nodes
signal load_paths
signal load_terrain
signal load_enclosure

signal ui_visibility ## Emitted by: inputController
