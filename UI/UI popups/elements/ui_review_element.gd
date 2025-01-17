extends PanelContainer

var description : String
var count : int

func _ready() -> void:
	%Description.text = description
	%Count.text = str(count)
