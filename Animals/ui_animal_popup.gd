extends Control

var animal_scene : Animal

@export var male_icon : Texture
@export var female_icon : Texture

signal popup_closed

func _ready():
	%CloseButton.pressed.connect(on_popup_closed)
	%SellAnimal.pressed.connect(on_sell_animal)
	
	%AnimalInfoButton.pressed.connect(on_animal_info_pressed)
	
	if animal_scene.animal_gender == IdRefs.ANIMAL_GENDERS.MALE:
		%GenderIcon.texture = male_icon
	else:
		%GenderIcon.texture = female_icon
	
	%AnimalName.text = animal_scene.animal_res.name
	
	%DebugPathfinding.pressed.connect(animal_scene.debug_toggle_pathfinding_draw)
	%DebugDie.pressed.connect(animal_scene.die)
	
	%FeedLabel.text = str(animal_scene.animal_res.feed)
	if animal_scene.months_in_zoo > 0:
		%ZooTimeLabel.text = Helpers.format_months_to_years_and_months(animal_scene.months_in_zoo)
	else:
		%ZooTimeLabel.text = "Just arrived"
	%AgeLabel.text = Helpers.format_months_to_years_and_months(animal_scene.months_of_life)
	if animal_scene.is_infant:
		%MateStatus.text = "Animal is infant"
	else:
		if animal_scene.look_for_mate():
			%MateStatus.text = "Animal is looking for mate"
		elif animal_scene.is_animal_pregnant:
			%MateStatus.text = "Pregnant"
		else:
			%MateStatus.text = ""
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%HungerProgressBar.value = animal_scene.needs_hunger
	%RestProgressBar.value = animal_scene.needs_rest
	%FunProgressBar.value = animal_scene.needs_play
	
	update_preferences()

func on_popup_closed():
	popup_closed.emit()
	
func on_sell_animal():
	animal_scene.remove_animal()
	queue_free()

func on_debug_update():
	animal_scene.update_habitat_satifaction()
	
func update_preferences():
	if fmod(animal_scene.habitat_happiness, 1.0) == 0.5:
		%overall_happiness_value.text = str(animal_scene.habitat_happiness) + ' / 5'
	else:
		%overall_happiness_value.text = str(int(animal_scene.habitat_happiness)) + ' / 5'
	
	if animal_scene.preference_terrain_satisfied:
		%preference_terrain.text = "I'm satisfied with the terrain"
		%preference_terrain.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		if animal_scene.is_there_disliked_terrain:
			%preference_terrain.add_theme_color_override("font_color", Color('#fe0005'))
			%preference_terrain.text = "I dislike the terrain type " + str(animal_scene.disliked_terrains_in_habitat[0])
		else:
			%preference_terrain.add_theme_color_override("font_color", Color('#fe0005'))
			if !animal_scene.lacking_terrain_types.is_empty():
				%preference_terrain.text = "Something is wrong with the terrain, I need  more " + str(animal_scene.lacking_terrain_types[0])


	if animal_scene.preference_water_satisfied:
		%preference_water.text = "I like the lake!"
		%preference_water.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		if animal_scene.animal_res.needs_water:
			%preference_water.add_theme_color_override("font_color", Color('#fe0005'))
			%preference_water.text = "I miss water"
		else:
			%preference_water.visible = false
			
	if animal_scene.preference_habitat_size_satisfied:
		%preference_habitat_size.text = "My habitat has a good size"
		%preference_habitat_size.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		%preference_habitat_size.add_theme_color_override("font_color", Color('#fe0005'))
		%preference_habitat_size.text = "I feel claustrophobic"

	if animal_scene.preference_vegetation_coverage_satisfied:
		%preference_vegetation_coverage.text = "I love the vegetation around here"
		%preference_vegetation_coverage.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		if animal_scene.too_little_vegetation:
			%preference_vegetation_coverage.add_theme_color_override("font_color", Color('#fe0005'))
			%preference_vegetation_coverage.text = "My habitat's vegetation is too bare"
		elif animal_scene.too_much_vegetation:
			%preference_vegetation_coverage.add_theme_color_override("font_color", Color('#fe0005'))
			%preference_vegetation_coverage.text = "My habitat has too much vegetation"
		
	if animal_scene.preference_herd_size_satisfied:
		%preference_herd_size.text = "I have enough friends"
		%preference_herd_size.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		%preference_herd_size.add_theme_color_override("font_color", Color('#fe0005'))
		%preference_herd_size.text = "I'd like to have more friends"
		
	if animal_scene.preference_herd_density_satisfied:
		%preference_herd_density.text = "Me and my friends have enough space"
		%preference_herd_density.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		%preference_herd_density.add_theme_color_override("font_color", Color('#fe0005'))
		%preference_herd_density.text = "There is not enough space for all of us"

	if animal_scene.favorite_tree_satisfied:
		%preference_herd_density.text = "I love my favorite tree"
		%preference_herd_density.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		%preference_herd_density.add_theme_color_override("font_color", Color('#fe0005'))
		%preference_herd_density.text = "I miss my favorite tree " + str(animal_scene.animal_res.favorite_tree)

func on_animal_info_pressed():
	SignalBus.open_popup_with_data.emit('AnimalInfo', {'resource': animal_scene.animal_res})
