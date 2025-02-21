extends Control

var animal_res : animal_resource

signal popup_closed

func _ready() -> void:
	%AnimalName.text = tr(animal_res.tr_name)
	
	for terrain_key in animal_res.terrain_preference:
		var terrain_label = Label.new()
		terrain_label.text = str(int(animal_res.terrain_preference[terrain_key]))+ '% ' + str(ContentManager.terrains[terrain_key].tr_name)
		%TerrainLabels.add_child(terrain_label)
	
	%BulldozerDecorationCheckBox.set_pressed_no_signal(animal_res.needs_water)
	
	%EnclosureSizeLabel.text = tr('UI_ANIMAL_INFO_MINIMUM_ENCLOSURE_SIZE') + str(animal_res.minimum_habitat_size) + ' ' + tr('UI_ANIMAL_INFO_CELLS')+ ' + ' + str(animal_res.minimum_cells_per_animal) + ' ' + tr('UI_ANIMAL_INFO_PER_ANIMAL')
	%HerdSizeLabel.text = str(animal_res.minimum_herd_size)
	if animal_res.minimum_vegetation_coverage < 0.2:
		%VegetationDensityLabel.text = tr('MINIMAL')
	elif animal_res.minimum_vegetation_coverage >= 0.2 and animal_res.minimum_vegetation_coverage < 0.35:
		%VegetationDensityLabel.text = tr('LOW')
	elif animal_res.minimum_vegetation_coverage >= 0.35 and animal_res.minimum_vegetation_coverage < 0.65:
		%VegetationDensityLabel.text = tr('MEDIUM')
	elif animal_res.minimum_vegetation_coverage > 0.65:
		%VegetationDensityLabel.text = tr('HIGH')
	
	
	%FavoriteTreeLabel.text = tr(ContentManager.trees[animal_res.favorite_tree].tr_name).to_lower()
	%FenceLevelLabel.text = str(animal_res.minimum_fence_level)
	%ShelterLevelLabel.text = str(animal_res.minimum_shelter_level)
	
	%FeedTypeLabel.text = str(animal_res.feed)
	%LifetimeLabel.text = Helpers.format_months_to_years_and_months(animal_res.months_of_expected_lifetime)
	%PregnancyLabel.text = Helpers.format_months_to_years_and_months(animal_res.months_of_pregnancy)
	%AdulthoodLabel.text = Helpers.format_months_to_years_and_months(animal_res.months_to_adulthood)
	%RatingLabel.text = str(animal_res.animal_rating)
	
	%AnimalThumb.texture = animal_res.thumb
	
	%CloseButton.pressed.connect(popup_closed.emit)
