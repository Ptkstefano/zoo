extends PanelContainer

var product_name
var cost
var id

signal cost_changed

func _ready() -> void:
	%Minus.pressed.connect(on_value_change.bind(-0.1))
	%Plus.pressed.connect(on_value_change.bind(0.1))
	$Element/HBoxContainer/HBoxContainer/Price.text = "$" + str(cost).pad_decimals(2)
	## TODO - Grab name
	$Element/HBoxContainer/ProductName.text = str(product_name)
	
func on_value_change(value):
	cost = clampf(cost + value, 0, 50)
	cost_changed.emit(id, cost)
	$Element/HBoxContainer/HBoxContainer/Price.text = "$" + str(cost).pad_decimals(2)
