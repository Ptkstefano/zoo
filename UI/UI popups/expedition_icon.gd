extends StaticBody2D

@export var expedition_resource : expedition_resource
	
var scale_tween : Tween
var modulate_tween : Tween

var is_selected : bool = false

@onready var light = find_child('PointLight2D')

func selected():
	if !is_selected:
		is_selected = true
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.65).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.65).set_trans(Tween.TRANS_QUAD)
		tween.set_loops()
		tween.play()
		scale_tween = tween
		modulate = Color.WHITE
		light.enabled = true
		#var tween_2 = create_tween()
		#tween_2.tween_property(self, "modulate", Color.WHITE, 0.65).set_trans(Tween.TRANS_QUAD)
		#tween_2.tween_property(self, "modulate", Color('#e3e3e3'), 0.65).set_trans(Tween.TRANS_QUAD)
		#tween_2.set_loops()
		#tween_2.play()
		#modulate_tween = tween_2
		

func deselect():
	if is_selected:
		light.enabled = false
		is_selected = false
		scale = Vector2.ONE
		modulate = Color('#e3e3e3')
		scale_tween.kill()
		scale_tween = null
		#modulate_tween.kill()
		#modulate_tween = null
