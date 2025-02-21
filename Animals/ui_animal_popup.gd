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
	
	%AnimalName.text = tr(animal_scene.animal_res.tr_name) + ' #' + str(animal_scene.id)
	
	%DebugPathfinding.pressed.connect(animal_scene.debug_toggle_pathfinding_draw)
	%DebugDie.pressed.connect(animal_scene.die)
	%DebugHungry.pressed.connect(set_animal_need.bind('hunger'))
	%DebugTired.pressed.connect(set_animal_need.bind('rest'))
	%DebugBored.pressed.connect(set_animal_need.bind('play'))
	
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
		%preference_terrain.text = tr('UI_ANIMAL_TERRAIN_SATISFIED')
		%preference_terrain.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		if animal_scene.is_there_disliked_terrain:
			%preference_terrain.add_theme_color_override("font_color", Color('#fe0005'))
			%preference_terrain.text = tr('UI_ANIMAL_TERRAIN_DISLIKE') + tr(ContentManager.terrains[animal_scene.disliked_terrains_in_habitat[0]])
		else:
			%preference_terrain.add_theme_color_override("font_color", Color('#fe0005'))
			if !animal_scene.lacking_terrain_types.is_empty():
				%preference_terrain.text = tr('UI_ANIMAL_NEED_MORE_TERRAIN') + tr(ContentManager.terrains[animal_scene.lacking_terrain_types[0]].tr_name).to_lower()


	if animal_scene.preference_water_satisfied:
		%preference_water.text = tr('UI_ANIMAL_HAS_WATER')
		%preference_water.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		if animal_scene.animal_res.needs_water:
			%preference_water.add_theme_color_override("font_color", Color('#fe0005'))
			%preference_water.text = tr('UI_ANIMAL_WANTS_WATER')
		else:
			%preference_water.visible = false
			
	if animal_scene.preference_habitat_size_satisfied:
		%preference_habitat_size.text = tr('UI_ANIMAL_GOOD_ENCLOSURE_SIZE')
		%preference_habitat_size.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		%preference_habitat_size.add_theme_color_override("font_color", Color('#fe0005'))
		%preference_habitat_size.text = tr('UI_ANIMAL_BAD_ENCLOSURE_SIZE')

	if animal_scene.preference_vegetation_coverage_satisfied:
		%preference_vegetation_coverage.text = tr('UI_ANIMAL_GOOD_VEGETATION')
		%preference_vegetation_coverage.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		if animal_scene.too_little_vegetation:
			%preference_vegetation_coverage.add_theme_color_override("font_color", Color('#fe0005'))
			%preference_vegetation_coverage.text = tr('UI_ANIMAL_LITTLE_VEGETATION')
		elif animal_scene.too_much_vegetation:
			%preference_vegetation_coverage.add_theme_color_override("font_color", Color('#fe0005'))
			%preference_vegetation_coverage.text = tr('UI_ANIMAL_TOO_MUCH_VEGETATION')
		
	if animal_scene.preference_herd_size_satisfied:
		%preference_herd_size.text = tr('UI_ANIMAL_ENOUGH_FRIENDS')
		%preference_herd_size.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		%preference_herd_size.add_theme_color_override("font_color", Color('#fe0005'))
		%preference_herd_size.text = tr('UI_ANIMAL_NEEDS_FRIENDS')
		
	#if animal_scene.preference_herd_density_satisfied:
		#%preference_herd_density.text = tr('UI_ANIMAL_ENOUGH_SPACE')
		#%preference_herd_density.add_theme_color_override("font_color", Color('#76ad6f'))
	#else:
		#%preference_herd_density.add_theme_color_override("font_color", Color('#fe0005'))
		#%preference_herd_density.text = tr('UI_ANIMAL_NEEDS_SPACE')

	if animal_scene.favorite_tree_satisfied:
		%preference_favorite_tree.text = tr('UI_ANIMAL_HAS_FAVORITE_TREE')
		%preference_favorite_tree.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		%preference_favorite_tree.add_theme_color_override("font_color", Color('#fe0005'))
		%preference_favorite_tree.text = tr('UI_ANIMAL_NEEDS_FAVORITE_TREE') + tr(ContentManager.trees[animal_scene.animal_res.favorite_tree].tr_name).to_lower()

func on_animal_info_pressed():
	SignalBus.open_popup_with_data.emit('AnimalInfo', {'resource': animal_scene.animal_res})

func set_animal_need(need):
	if need == 'hunger':
		animal_scene.needs_hunger = 5.0
	if need == 'play':
		animal_scene.needs_play = 5.0
	if need == 'rest':
		animal_scene.needs_rest = 5.0
