extends CanvasLayer


var audio_bus_possible_levels = [-80,-60,-50,-40,-30,-20,-16,-12,-8,-4,0]

signal option_menu_closed

func _ready() -> void:
	print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	
	%MasterSlider.value_changed.connect(on_audio_bus_slider_change.bind('Master').bind(%MasterSlider))
	%SoundscapeSlider.value_changed.connect(on_audio_bus_slider_change.bind('Soundscape').bind(%SoundscapeSlider))
	%MusicSlider.value_changed.connect(on_audio_bus_slider_change.bind('Music').bind(%MusicSlider))
	
	%MasterMute.pressed.connect(on_audio_bus_mute_pressed.bind(%MasterMute).bind(%MasterSlider))
	%SoundscapeMute.pressed.connect(on_audio_bus_mute_pressed.bind(%SoundscapeMute).bind(%SoundscapeSlider))
	%MusicMute.pressed.connect(on_audio_bus_mute_pressed.bind(%MusicMute).bind(%MusicSlider))
	
	%CloseButton.pressed.connect(on_close_menu)
	set_up_audio_screen()
	
func on_close_menu():
	option_menu_closed.emit()
	GlobalConfigManager.save_config()
	queue_free()
	
func on_audio_bus_slider_change(value, slider, bus_name):
	print('slider change')
	var bus_idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_idx, audio_bus_possible_levels[int(slider.value)])
	if int(slider.value) == 0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
	set_up_audio_screen()
	
func on_audio_bus_mute_pressed(slider, button : CheckButton):
	print(button.button_pressed)
	if button.button_pressed:
		slider.value = 0
	else:
		slider.value = 10
	
func set_up_audio_screen():
	%MasterSlider.value = audio_bus_possible_levels.find(int(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))))
	%SoundscapeSlider.value = audio_bus_possible_levels.find(int(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Soundscape"))))
	%MusicSlider.value = audio_bus_possible_levels.find(int(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))))
	%MasterMute.button_pressed = AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
	%SoundscapeMute.button_pressed = AudioServer.is_bus_mute(AudioServer.get_bus_index("Soundscape"))
	%MusicMute.button_pressed = AudioServer.is_bus_mute(AudioServer.get_bus_index("Music"))
