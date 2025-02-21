extends Button


func _ready() -> void:
	pressed.connect(on_pressed)
	
func on_pressed():
	if TranslationServer.get_locale() == 'en':
		TranslationServer.set_locale('pt')
	else:
		TranslationServer.set_locale('en')
		
	text = tr('LANGUAGE')
