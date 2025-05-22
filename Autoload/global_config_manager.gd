extends Node

var config_file_path = "user://config_data.json"

func _ready() -> void:
	load_config()

func save_config():
	var saveFile = FileAccess.open(config_file_path, FileAccess.WRITE)
	
	var config_data = {}
	config_data['audio_bus_master_level'] = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	config_data['audio_bus_soundscape_level'] = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Soundscape"))
	config_data['audio_bus_music_level'] = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))

	config_data['language'] = TranslationServer.get_locale()

	var json_data = JSON.stringify(config_data)
	
	if json_data.is_empty():
		print('save failed')
		return
		
	saveFile.store_string(json_data)
	
func load_config():
	
	var file = FileAccess.open(config_file_path, FileAccess.READ)
	if !file:
		FileAccess.open(config_file_path, FileAccess.WRITE)
		save_config()
		return
		
	var data
	if file:
		var json = JSON.new()
		data = json.parse_string(file.get_as_text())  
			
	if !data:
		print('NO SAVE FILE FOUND')
		return
		
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), int(data['audio_bus_master_level']))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Soundscape"), int(data['audio_bus_soundscape_level']))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), int(data['audio_bus_music_level']))
	
	TranslationServer.set_locale(data.get('language', 'en'))
	
