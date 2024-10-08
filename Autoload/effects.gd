extends Node

var smoke_vfx = preload("res://vfx/visual_fx_smoke.tscn")
var smoke_vfx2 = preload("res://vfx/visual_fx_smoke2.tscn")

func wobble(scene):
	var tween = get_tree().create_tween()
	tween.tween_property(scene, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_EXPO)
	tween.chain().tween_property(scene, "scale", Vector2(0.95, 0.95), 0.1).set_trans(Tween.TRANS_EXPO)
	tween.chain().tween_property(scene, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_EXPO)
	
func smoke(pos):
	var fx = smoke_vfx.instantiate()
	fx.global_position = pos
	add_child(fx)
	
func smoke2(pos):
	var fx = smoke_vfx2.instantiate()
	fx.global_position = pos
	add_child(fx)
