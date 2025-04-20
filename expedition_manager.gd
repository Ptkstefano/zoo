extends Node

var hexagon_minigame_scene = preload("res://worldmap/expedition_hexagon_game/hexagon_game.tscn")

var game_instance

func start_expedition(chosen_expedition_resource : expedition_resource):
	game_instance = hexagon_minigame_scene.instantiate()
	game_instance.hidden_animals = [ContentManager.animals[chosen_expedition_resource.possible_animals.pick_random()], ContentManager.animals[chosen_expedition_resource.possible_animals.pick_random()]]
	game_instance.hexagon_ended.connect(on_game_ended)
	FinanceManager.remove(chosen_expedition_resource.cost, IdRefs.PAYMENT_REMOVE_TYPES.EXPEDITION)
	
	get_tree().get_first_node_in_group('MinigameViewport').add_child(game_instance)
	get_tree().get_first_node_in_group('MinigameCanvas').show()
	return


func on_game_ended():
	for animal in game_instance.captured_animals:
		AnimalStorageManager.create_animal(animal)
	get_tree().get_first_node_in_group('MinigameCanvas').hide()
	game_instance.queue_free()
