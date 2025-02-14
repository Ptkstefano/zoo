extends TextureRect

func _ready() -> void:
	await get_tree().create_timer(0.15).timeout
	pivot_offset = Vector2(size.x * 0.5, size.y * 0.5)
	scale_tween()
	

func scale_tween():
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.025, 1.025), 3).set_trans(Tween.TRANS_QUART)
	tween.tween_property(self, "scale", Vector2(0.975, 0.975), 3).set_trans(Tween.TRANS_QUART)
	tween.play()
	tween.tween_callback(scale_tween)
