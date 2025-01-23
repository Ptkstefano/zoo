extends Control

var animal_res : animal_resource

signal popup_closed

func _ready() -> void:
	%AnimalName.text = str(animal_res.name)
	
	for terrain_key in animal_res.terrain_preference:
		var terrain_label = Label.new()
		terrain_label.text = str(int(animal_res.terrain_preference[terrain_key]))+ '% ' + str(terrain_key)
		%TerrainLabels.add_child(terrain_label)
	
	%BulldozerDecorationCheckBox.set_pressed_no_signal(animal_res.needs_water)
	
	%EnclosureSizeLabel.text = 'Minimum enclosure size: ' + str(animal_res.minimum_habitat_size) + ' cells + ' + str(animal_res.minimum_cells_per_animal) + ' per animal'
	%HerdSizeLabel.text = str(animal_res.minimum_herd_size)
	if animal_res.minimum_vegetation_coverage < 0.2:
		%VegetationDensityLabel.text = "minimal"
	elif animal_res.minimum_vegetation_coverage >= 0.2 and animal_res.minimum_vegetation_coverage < 0.35:
		%VegetationDensityLabel.text = "low"
	elif animal_res.minimum_vegetation_coverage >= 0.35 and animal_res.minimum_vegetation_coverage < 0.65:
		%VegetationDensityLabel.text = "medium"
	elif animal_res.minimum_vegetation_coverage > 0.65:
		%VegetationDensityLabel.text = "high"
	
	
	%FavoriteTreeLabel.text = str(animal_res.favorite_tree)
	%FenceLevelLabel.text = str(animal_res.minimum_fence_level)
	%ShelterLevelLabel.text = str(animal_res.minimum_shelter_level)
	
	%FeedTypeLabel.text = str(animal_res.feed)
	%LifetimeLabel.text = Helpers.format_months_to_years_and_months(animal_res.months_of_expected_lifetime)
	%PregnancyLabel.text = Helpers.format_months_to_years_and_months(animal_res.months_of_pregnancy)
	%AdulthoodLabel.text = Helpers.format_months_to_years_and_months(animal_res.months_to_adulthood)
	%RatingLabel.text = str(animal_res.animal_rating)
	
	%AnimalThumb.texture = animal_res.thumb
	
	%CloseButton.pressed.connect(popup_closed.emit)
