extends MarginContainer


func _ready():
	get_tree().get_root().size_changed.connect(resize_ui)
	resize_ui()
	
func resize_ui():
	if DisplayServer.window_get_size().y < 1080:
		add_theme_constant_override("margin_bottom", 100)
		add_theme_constant_override("margin_top", 50)
		add_theme_constant_override("margin_left", 50)
		add_theme_constant_override("margin_right", 50)
		
	else:
		add_theme_constant_override("margin_bottom", 150)
		add_theme_constant_override("margin_top", 100)
		add_theme_constant_override("margin_left", 200)
		add_theme_constant_override("margin_right", 200)
