extends TextureRect

func _ready() -> void:
	await get_tree().create_timer(0.15).timeout
	pivot_offset = Vector2(size.x * 0.5, size.y * 0.5)
	scale_tween()
	

func scale_tween():
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 2).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 2).set_trans(Tween.TRANS_CUBIC)
	tween.play()
	tween.tween_callback(scale_tween)
