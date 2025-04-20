extends CanvasLayer

@export var notification_scene : PackedScene

func _ready() -> void:
	SignalBus.tooltip.connect(on_tooltip_emitted)
	SignalBus.money_tooltip.connect(on_money_tooltip_emitted)
	
func on_tooltip_emitted(tooltip_text, emit_position):
	var label = notification_scene.instantiate()
	label.text = tooltip_text
	var pos
	var viewport_size = get_viewport().get_visible_rect().size
	if emit_position:
		pos = emit_position + Vector2(viewport_size.x * -0.5 - 25, viewport_size.y * -0.5 -50)
	else:
		pos = $"../InputController".touch_start_global_pos + Vector2(viewport_size.x * -0.5 - 25, viewport_size.y * -0.5 -50)
	label.position = pos
	add_child(label)
	label.show()
	var tween = get_tree().create_tween()
	tween.parallel()
	tween.tween_property(label, 'modulate', Color.TRANSPARENT, 2).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(label, 'position', Vector2(label.position.x, label.position.y - 50), 3)
	
	await get_tree().create_timer(3).timeout
	label.hide()
	
func on_money_tooltip_emitted(value, earned : bool, global_pos : Vector2):
	if !GameManager.game_running:
		return
	var label = notification_scene.instantiate()
	label.text = "$"+str(value)
	var viewport_size = get_viewport().get_visible_rect().size
	var pos = global_pos + Vector2(viewport_size.x * -0.5 - 25, viewport_size.y * -0.5 - 50)
	if !earned:
		label.add_theme_color_override("font_color", ColorRefs.negative_red)
	else:
		label.add_theme_color_override("font_color", ColorRefs.positive_green)
	label.global_position = pos
	add_child(label)
	label.show()
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(label, 'modulate', Color.TRANSPARENT, 2).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(label, 'position', Vector2(label.position.x, label.position.y - 50), 3)
	
	await get_tree().create_timer(3).timeout
	label.hide()
