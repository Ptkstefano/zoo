extends CanvasLayer

class_name ConfirmationPopup

var callback : Callable
var data
var text : String

signal confirmed
signal canceled



func _ready():
	%ConfirmButton.pressed.connect(button_pressed.bind(true))
	%CancelButton.pressed.connect(button_pressed.bind(false))
	set_text(text)

func set_text(str):
	%Label.text = str(str)

func button_pressed(accepted):
	if accepted:
		confirmed.emit()
		callback.call(data)
		queue_free()
	else:
		canceled.emit()
		queue_free()
