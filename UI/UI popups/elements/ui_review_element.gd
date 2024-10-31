extends HBoxContainer

var description : String
var count : int

func _ready() -> void:
	$MarginContainer/Description.text = description
	$MarginContainer/Count.text = str(count)
