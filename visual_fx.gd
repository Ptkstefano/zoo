extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(name)
	$AnimationPlayer.play('start')
	$AnimationPlayer.animation_finished.connect(on_finish)

func on_finish(anim):
	queue_free()
