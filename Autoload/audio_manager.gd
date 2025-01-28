extends Node

@export var sfx_path_placed : AudioStream
@export var sfx_path_removed : AudioStream

@export var sfx_vegetation_placed : Array[AudioStream]
@export var sfx_tree_placed : Array[AudioStream]

func play_stream(stream):
	$AudioStreamPlayer.stream = get(stream)
	$AudioStreamPlayer.play()

func play_vegetation_placed():
	$ConstructionPlayer.stream = sfx_vegetation_placed.pick_random()
	$ConstructionPlayer.play()

func play_tree_placed():
	$ConstructionPlayer.stream = sfx_tree_placed.pick_random()
	$ConstructionPlayer.play()

func play_path_placed():
	$ConstructionPlayer.stream = sfx_path_placed
	$ConstructionPlayer.play()
