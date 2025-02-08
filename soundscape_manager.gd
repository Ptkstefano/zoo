extends Node

var peeps_in_screen : int = 0:
	set(value):
		peeps_in_screen = max(value, 0)
var trees_in_screen : int = 0
var lakes_in_screen : int = 0

var peep_weight : int
var tree_weight : int

## this value is set directly by the camera
var camera_zoom : int = 0

var crowd_player : AudioStreamPlaybackInteractive
var vegetation_player : AudioStreamPlaybackInteractive

var current_crowd_clip : int = 0
var crowd_clip_index : int = 0

var current_vegetation_clip : int = 0
var vegetation_clip_index : int = 0

var close_up_volume

var close_up_bus_index : int = 0

#var crowd_zoom_volume = [-20, -15, -10, -7, -3, 0]
#var vegetation_zoom_volume = [-25, -20, -15, -12, -8, -5]

var crowd_zoom_volume = [-25, -20, -16, -12, -8, -5]
var vegetation_zoom_volume = [-30, -22, -18, -15, -12, -8]


func _ready():
	SignalBus.game_started.connect(on_start)
	
func on_start():
	%CrowdPlayer.play()
	%GeneralAmbiancePlayer.play()
	%VegetationPlayer.play()
	close_up_bus_index = AudioServer.get_bus_index("CloseUp")
	crowd_player = %CrowdPlayer.get_stream_playback()
	vegetation_player = %VegetationPlayer.get_stream_playback()


func _physics_process(delta: float) -> void:
	#var close_up_volume = (camera_zoom * 0.2) * 20 - 20
	play_dynamic_close_up_soundscape()

func play_cash_register():
	$CashRegister.volume_db = crowd_zoom_volume[camera_zoom]
	$CashRegister.play()

func play_dynamic_close_up_soundscape():
	%CrowdPlayer.volume_db = lerpf(%CrowdPlayer.volume_db, crowd_zoom_volume[camera_zoom], 0.1)
	%VegetationPlayer.volume_db =  lerpf(%VegetationPlayer.volume_db, vegetation_zoom_volume[camera_zoom], 0.1)
	
	
	peep_weight = peeps_in_screen * (camera_zoom * 0.8)
	tree_weight = trees_in_screen * (camera_zoom * 1)
	
	if peep_weight < 20:
		crowd_clip_index = 0
	elif peep_weight < 40:
		crowd_clip_index = 1
	elif peep_weight < 70:
		crowd_clip_index = 2
	elif peep_weight < 140:
		crowd_clip_index = 3
	else:
		crowd_clip_index = 4
	
	if tree_weight < 15:
		if peep_weight < 50:
			vegetation_clip_index = 0
		else:
			vegetation_clip_index = 3
		
	else:
		if lakes_in_screen > 0:
			vegetation_clip_index = 1
		else:
			vegetation_clip_index = 2
	
	if crowd_clip_index != current_crowd_clip:
		current_crowd_clip = crowd_clip_index
		crowd_player.switch_to_clip(current_crowd_clip)

	if vegetation_clip_index != current_vegetation_clip:
		current_vegetation_clip = vegetation_clip_index
		vegetation_player.switch_to_clip(current_vegetation_clip)
