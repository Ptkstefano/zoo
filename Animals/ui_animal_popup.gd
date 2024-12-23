extends Control

var animal_scene : Animal

func _ready():
	%CloseButton.pressed.connect(on_close)
	%SellAnimal.pressed.connect(on_sell_animal)
	
	%AnimalName.text = animal_scene.animal_res.name
	
	%DebugUpdatePreferences.pressed.connect(on_debug_update)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%HungerProgressBar.value = animal_scene.needs_hunger
	%RestProgressBar.value = animal_scene.needs_rest
	%FunProgressBar.value = animal_scene.needs_play
	
	update_preferences()

func on_close():
	queue_free()

func on_sell_animal():
	animal_scene.remove_animal()
	queue_free()

func on_debug_update():
	animal_scene.update_habitat_satifaction()
	
func update_preferences():
	if animal_scene.preference_terrain_satisfied:
		%preference_terrain.text = "I'm satisfied with the terrain"
		%preference_terrain.add_theme_color_override("font_color", Color('#76ad6f'))
	else:
		%preference_terrain.add_theme_color_override("font_color", Color('#fe0005'))
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
