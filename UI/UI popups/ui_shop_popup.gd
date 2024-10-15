extends CanvasLayer

var shop_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%CloseButton.pressed.connect(queue_free)
	%RemoveBuildingButton.pressed.connect(on_remove_building)
	

func on_remove_building():
	shop_node.remove_building()
	queue_free()
