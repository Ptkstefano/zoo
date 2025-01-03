extends Node

signal tooltip
signal money_tooltip 

signal obstacle_changed
signal vegetation_placed

signal open_popup
signal open_box ## Emitted by UI

signal peep_navigation_changed
signal path_erased
signal path_changed

signal clear_highlight ## Received by highlightLayer

signal update_peeps_cached_positions ## Emitted by: save_manager, received by peepManager

signal enclosure_removed  ## Emitted by: enclosure_scene

signal save_game
signal game_started

signal money_changed

signal ui_visibility ## Emitted by: inputController

signal pass_month ## Emitted by: TimeManager

signal set_debug_label_text
