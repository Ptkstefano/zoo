extends Node

signal tool_selected
signal tool_deselected
signal free_camera
signal rotate_building
signal building_placed
signal building_built
signal construction_menu_closed
signal animal_placed

signal animal_bought

signal tooltip
signal money_tooltip 
signal notification
signal tooltip_with_pos

signal obstacle_changed
signal vegetation_placed
signal update_enclosure_land_areas

signal open_popup
signal open_box ## Emitted by UI
signal open_confirmation_popup
signal open_popup_with_data
signal open_construction_menu ## Emitted by buttons in UI
signal open_options_menu

signal peep_navigation_changed
signal path_erased
signal path_changed
signal path_layer_updated

signal activate_quest_giver ## Emitted by QuestManager and received by possible quest givers
signal quest_activated ## Emitted bi quest giver so that manager can properly start quest
signal quest_started ## Emitted by QuestManager with quest_resource


signal speech_started
signal speech_ended


signal clear_highlight ## Received by highlightLayer

signal update_cached_positions

signal move_camera_to ## Received by the camera. Needs global position as argument

signal enclosure_removed  ## Emitted by: enclosure_scene

signal hire_staff ## Emitted by mgmt UI to staffManager

signal save_game
signal game_started
signal game_stopped

signal money_changed

signal ui_visibility ## Emitted by: inputController
signal ui_element_selected ## Emitted by individual elements when selected and received by other elements

#signal pass_month ## Emitted by: TimeManager

signal set_debug_label_text
signal debug_clear_peeps

signal exiting_game_scene ## Emmited by options menu -> used to update autoloads
signal instantiating_main_menu ## Emmited by main_menu on ready -> used to update autoloads

## Just as debug for now
signal start_night
signal start_day
