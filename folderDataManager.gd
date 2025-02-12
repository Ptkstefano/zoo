extends Node

var userfolder_path = "user://"

var sandbox_save_folder_path = "sandbox_saves/"
var story_save_folder_path = "story_saves"

var sandbox_saves = []

func _ready() -> void:
	initialize_folders()
		
	var sandbox_saves_dir = DirAccess.open(userfolder_path + sandbox_save_folder_path)
	if sandbox_saves_dir:
		var sandbox_saves_file_list = sandbox_saves_dir.get_files()
		for file_name in sandbox_saves_file_list:
			var save_data = {}
			save_data['file_name'] = file_name
			save_data['zoo_name'] = file_name
			var file = FileAccess.open(userfolder_path + sandbox_save_folder_path + file_name, FileAccess.READ)
			if file:
				var json = JSON.new()
				var data = json.parse_string(file.get_as_text()) 
				if !data: 
					var backup_file = FileAccess.open(userfolder_path + sandbox_save_folder_path + 'backup/' + file_name, FileAccess.READ)
					data = json.parse_string(backup_file.get_as_text())  
				save_data['zoo_name'] = data['zoo_manager_data'].get('zoo_name', file_name)
			sandbox_saves.append(save_data)
			
	else:
		print('error')

func initialize_folders():
	var dir = DirAccess.open(userfolder_path)
	if !dir.dir_exists(sandbox_save_folder_path):
		dir.make_dir(sandbox_save_folder_path)
		var sandbox_saves_dir = DirAccess.open(userfolder_path + sandbox_save_folder_path)
		sandbox_saves_dir.make_dir('backup/')
	if !dir.dir_exists(story_save_folder_path):
		dir.make_dir(story_save_folder_path)

func delete_save_game(save_file):
	var save_file_path = userfolder_path + sandbox_save_folder_path + save_file
	DirAccess.remove_absolute(save_file_path)
