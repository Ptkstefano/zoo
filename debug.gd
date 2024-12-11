extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.set_debug_label_text.connect(on_text)
	text = str(ContentManager.products.values())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_text(a):
	text = a
	await get_tree().create_timer(5).timeout
	text = ''
