extends Node

@export var music_items : Array[AudioStream]

func _ready() -> void:
	$MusicPlayer.finished.connect(on_audio_finished)

func start():
	if $MusicPlayer.playing:
		return
	var random_audio = music_items.pick_random()
	$MusicPlayer.stream = random_audio
	$MusicPlayer.play()
	
func on_audio_finished():
	await get_tree().create_timer(60).timeout
