extends VBoxContainer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(on_show)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_show():
	scale = Vector2(0,1)
	var tween = get_tree().create_tween()
	await tween.tween_property(self, "scale", Vector2(1,1), 0.7).set_trans(Tween.TRANS_EXPO)
