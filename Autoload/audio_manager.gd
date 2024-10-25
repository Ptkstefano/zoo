extends Node

@export var sfx_path_placed : AudioStream
@export var sfx_path_removed : AudioStream

func play_stream(stream):
	$AudioStreamPlayer.stream = get(stream)
	$AudioStreamPlayer.play()
