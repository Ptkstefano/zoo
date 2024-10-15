extends Node2D


## Script used in instance of visual fx
func _ready() -> void:
	$AnimationPlayer.play('start')
	$AnimationPlayer.animation_finished.connect(on_finish)

func on_finish(anim):
	queue_free()
