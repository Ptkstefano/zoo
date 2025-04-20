extends Control

var product_ids = []

@export var product_element : PackedScene

signal product_selected

func _ready() -> void:
	%Close.pressed.connect(queue_free)
	for id in product_ids:
		var element = product_element.instantiate()
		element.product_id = id
		element.product_selected.connect(on_product_selected)
		%ProductList.add_child(element)


func on_product_selected(product_id):
	product_selected.emit(product_id)
	queue_free()
	return
