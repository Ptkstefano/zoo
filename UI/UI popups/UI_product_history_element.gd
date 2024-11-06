extends HBoxContainer

var product_name = ''
var sells : int = 0

func _ready():
	$Name.text = product_name
	$Sells.text = str(sells)
