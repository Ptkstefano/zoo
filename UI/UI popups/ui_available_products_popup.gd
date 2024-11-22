extends CanvasLayer

var products = []

@export var product_element : PackedScene

signal product_selected

func _ready() -> void:
	%Close.pressed.connect(queue_free)
	for product in products:
		var element = product_element.instantiate()
		element.product_res = product
		element.product_selected.connect(on_product_selected)
		%ProductList.add_child(element)


func on_product_selected(product_res):
	product_selected.emit(product_res)
	queue_free()
	return
