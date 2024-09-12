extends CanvasLayer

var building_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%CloseButton.pressed.connect(queue_free)
	%RemoveBuildingButton.pressed.connect(on_remove_building)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_remove_building():
	building_node.remove_building()
	queue_free()
