extends Node


func wobble(scene):
	var tween = get_tree().create_tween()
	tween.tween_property(scene, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_EXPO)
	tween.chain().tween_property(scene, "scale", Vector2(0.95, 0.95), 0.1).set_trans(Tween.TRANS_EXPO)
	tween.chain().tween_property(scene, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_EXPO)
