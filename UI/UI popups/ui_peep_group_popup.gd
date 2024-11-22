extends Control

var peep_group_node : PeepGroup

func _ready():
	update_popup_data()
	%CloseButton.pressed.connect(queue_free)


func update_popup_data():
	if !is_instance_valid(peep_group_node):
		queue_free()
		return
	%peep_n.text = str(peep_group_node.peep_count)
	%minimum_product_level.text = str(peep_group_node.min_product_level)
	if peep_group_node.min_utility_score_tolerance > 1.25:
		%product_cost_tolerance.text = "Low"
	elif peep_group_node.min_utility_score_tolerance < 0.90:
		%product_cost_tolerance.text = "High"
	else:
		%product_cost_tolerance.text = "Medium"
		
	%HungerProgressBar.value = peep_group_node.needs_hunger
	%ToiletProgressBar.value = peep_group_node.needs_toilet
	%RestProgressBar.value = peep_group_node.needs_rest
	
	%n_species_seen.text = str(peep_group_node.observed_animals.size())
	%n_animals_yet_to_see.text = str(peep_group_node.group_desired_destinations.size())
	%favorite_animal.text = str(ContentManager.animals[peep_group_node.favorite_animal].name)
	
	%money_spent.text = str(peep_group_node.spent_money)
	
	
	
	for child in %SeenAnimalsList.get_children():
		child.queue_free()
	
	for animal in peep_group_node.observed_animals:
		var label = Label.new()
		label.text = str(ContentManager.animals[animal].name)
		%SeenAnimalsList.add_child(label)
		
	for child in %AnimalsToSeeList.get_children():
		child.queue_free()
		
	for animal in peep_group_node.group_desired_animals:
		#if animal not in peep_group_node.observed_animals:
		var label = Label.new()
		label.text = str(ContentManager.animals[animal].name)
		%AnimalsToSeeList.add_child(label)
		
	for child in %InventoryList.get_children():
		child.queue_free()

	for item in peep_group_node.peep_group_inventory:
		var label = Label.new()
		label.text = str(item.name) + ' x ' + str(peep_group_node.peep_count)
		%InventoryList.add_child(label)
		
	for child in %InventoryList.get_children():
		child.queue_free()
		
	print(peep_group_node.modifiers)
	for modifier in peep_group_node.modifiers:
		var label = Label.new()
		label.text = str(ModifierManager.peep_modifiers[modifier].description)
		%ThoughtList.add_child(label)
		

func _process(delta: float) -> void:
	update_popup_data()
