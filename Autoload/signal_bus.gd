extends Node

signal tooltip
signal money_tooltip 
signal notification

signal obstacle_changed
signal vegetation_placed
signal update_enclosure_land_areas

signal open_popup
signal open_box ## Emitted by UI
signal open_confirmation_popup
signal open_popup_with_data

signal peep_navigation_changed
signal path_erased
signal path_changed
signal path_layer_updated

signal clear_highlight ## Received by highlightLayer

signal update_peeps_cached_positions ## Emitted by: save_manager, received by peepManager
signal update_animals_cached_positions

signal move_camera_to ## Received by the camera. Needs global position as argument

signal enclosure_removed  ## Emitted by: enclosure_scene

signal hire_staff ## Emitted by mgmt UI to staffManager

signal save_game
signal game_started

signal money_changed

signal ui_visibility ## Emitted by: inputController

signal pass_month ## Emitted by: TimeManager

signal set_debug_label_text
