extends CanvasLayer

@export var ui_confirmation_popup : PackedScene

func _ready() -> void:
	SignalBus.open_confirmation_popup.connect(open_confirmation_popup)

func open_confirmation_popup(callback, popup_text, data):
	var confirmation_popup = ui_confirmation_popup.instantiate()
	confirmation_popup.callback = callback
	confirmation_popup.text = popup_text
	confirmation_popup.data = data
	add_child(confirmation_popup)
