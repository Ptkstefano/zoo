extends Control

var animal_data

signal popup_closed

func _ready() -> void:
	for data in animal_data:
		var texture = TextureRect.new()
		texture.texture = data.icon
		texture.custom_minimum_size = Vector2(40,40)
		%TextureList.add_child(texture)
		
	%CloseButton.pressed.connect(popup_closed.emit)
