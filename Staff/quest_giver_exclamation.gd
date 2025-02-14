extends Sprite2D

func _ready() -> void:
	bounce_tween()
	

func bounce_tween():
	var tween = create_tween()
	tween.tween_property(self, "offset", Vector2(0, 2), 2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "offset", Vector2(0, -2), 2).set_trans(Tween.TRANS_SINE)
	tween.play()
	tween.tween_callback(bounce_tween)
