extends Node

var hexagon_minigame_scene = preload("res://worldmap/expedition_hexagon_game/hexagon_game.tscn")

var game_instance

func start_expedition(chosen_expedition_resource):
	game_instance = hexagon_minigame_scene.instantiate()
	game_instance.hexagon_ended.connect(on_game_ended)
	get_tree().get_first_node_in_group('MinigameViewport').add_child(game_instance)
	get_tree().get_first_node_in_group('MinigameCanvas').show()
	return


func on_game_ended():
	get_tree().get_first_node_in_group('MinigameCanvas').hide()
	game_instance.queue_free()
