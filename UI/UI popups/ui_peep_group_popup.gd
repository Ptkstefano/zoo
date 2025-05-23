extends Control

var peep_group_node : PeepGroup

@export var level_star : PackedScene

signal popup_closed

func _ready():
	update_popup_data()
	%CloseButton.pressed.connect(on_popup_closed)
	
	var zooManagerShopsLabel = Label.new()
	zooManagerShopsLabel.text = 'Zoo manager restaurant keys: ' + str(ZooManager.restaurants.keys())
	%DebugList.add_child(zooManagerShopsLabel)
	
	var zooManagerEateryLabel = Label.new()
	zooManagerEateryLabel.text = 'Zoo manager eatery keys: ' + str(ZooManager.eateries.keys())
	%DebugList.add_child(zooManagerEateryLabel)
	
	var peepGroupShopLabel = Label.new()
	peepGroupShopLabel.text = 'Target shop: ' + str(peep_group_node.target_building)
	%DebugList.add_child(peepGroupShopLabel)
	
	%ResetStuckDebug.pressed.connect(peep_group_node.check_if_group_stuck)
	
	%PeepGroupId.text = 'Peep group ' + str(peep_group_node.id)
	
	for child in %min_product_level.get_children():
		child.queue_free()
	for level in peep_group_node.min_product_level:
		var star_texture = level_star.instantiate()
		%min_product_level.add_child(star_texture)
	
	if peep_group_node.min_utility_score_tolerance > 1.25:
		%product_cost_tolerance.text = tr('LOW')
	elif peep_group_node.min_utility_score_tolerance < 0.90:
		%product_cost_tolerance.text = tr('HIGH')
	else:
		%product_cost_tolerance.text = tr('MEDIUM')

	%InfoButton.pressed.connect(toggle_menu.bind(%UI_PEEPGROUP_GROUP_INFO))
	%AnimalsButton.pressed.connect(toggle_menu.bind(%UI_PEEPGROUP_ANIMAL_SIGHTINGS))
	%MoneyButton.pressed.connect(toggle_menu.bind(%UI_PEEPGROUP_BUDGET))
	%ThoughtsButton.pressed.connect(toggle_menu.bind(%UI_PEEPGROUP_THOUGHTS))
	
	%InventoryList.columns = peep_group_node.peep_count


func toggle_menu(menu):
	for child in %TabContainer.get_children():
		child.hide()
		
	menu.show()



func on_popup_closed():
	popup_closed.emit()

func update_popup_data():
	if !is_instance_valid(peep_group_node):
		queue_free()
		return
	%peep_n.text = str(peep_group_node.peep_count)
	
	%HungerProgressBar.value = peep_group_node.needs_hunger
	%ToiletProgressBar.value = peep_group_node.needs_toilet
	%RestProgressBar.value = peep_group_node.needs_rest
	
	%n_species_seen.text = str(peep_group_node.observed_animals.size())
	%n_animals_yet_to_see.text = str(peep_group_node.group_desired_destinations.size())
	%favorite_animal.text = tr(ContentManager.animals[peep_group_node.favorite_animal].tr_name)
	
	%money_spent.text = str(peep_group_node.spent_money)
		
	for child in %SeenAnimalsIconList.get_children():
		child.queue_free()
	
	for animal in peep_group_node.observed_animals:
		var texture = TextureRect.new()
		texture.texture = ContentManager.animals[int(animal)].icon
		texture.custom_minimum_size = Vector2(80,80)
		%SeenAnimalsIconList.add_child(texture)
	
		
	for child in %AnimalsToSeeIconList.get_children():
		child.queue_free()
		
	for animal in peep_group_node.group_desired_animals:
		var texture = TextureRect.new()
		texture.texture = ContentManager.animals[int(animal)].icon
		texture.custom_minimum_size = Vector2(80,80)
		%AnimalsToSeeIconList.add_child(texture)
			
		
	for child in %InventoryList.get_children():
		child.queue_free()

	for item in peep_group_node.peep_group_inventory:
		for i in peep_group_node.peep_count:
			var texture = TextureRect.new()
			texture.texture = ContentManager.products[item.id].thumb
			texture.custom_minimum_size = Vector2(80,80)
			%InventoryList.add_child(texture)
		
		#var label = Label.new()
		#label.text = str(item.tr_name) + ' x ' + str(peep_group_node.peep_count)
		#%InventoryList.add_child(label)
		
	for child in %ThoughtList.get_children():
		child.queue_free()
		
	for thought in peep_group_node.thoughts:
		var label = Label.new()
		label.text = tr(ThoughtManager.peep_thoughts[thought].description)
		%ThoughtList.add_child(label)
		

func _process(delta: float) -> void:
	return
	#update_popup_data()
