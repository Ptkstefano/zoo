extends CanvasLayer

@export var notification_scene : PackedScene

func _ready() -> void:
	SignalBus.tooltip.connect(on_tooltip_emitted)
	
func on_tooltip_emitted(tooltip):
	var label = notification_scene.instantiate()
	label.text = tooltip
	var pos = ($"../InputController".touch_start_global_pos - $"../Camera2D".global_position);
	label.position = pos
	add_child(label)
	label.show()
	var tween = get_tree().create_tween()
	tween.tween_property(label, 'modulate', Color.TRANSPARENT, 2).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(label, 'position', Vector2(label.position.x, label.position.y - 50), 3)
	
	await get_tree().create_timer(3).timeout
	label.hide()
	
	
