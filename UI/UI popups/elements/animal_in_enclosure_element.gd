extends PanelContainer

var animal_scene : Animal

@export var gender_icon_textures : Array[Texture]


func _ready() -> void:
	%AnimalNameLabel.text = tr(animal_scene.animal_res.tr_name) + ' #' + str(animal_scene.id)
	%AgeLabel.text = Helpers.format_months_to_years_and_months(animal_scene.months_of_life)
	%GenderTexture.texture = gender_icon_textures[animal_scene.animal_gender]
	%ReleaseAnimalButton.pressed.connect(on_release_animal_pressed)
	%GoToAnimalButton.pressed.connect(on_go_to_animal_pressed)

func on_release_animal_pressed():
	animal_scene.remove_animal()
	queue_free()
	return
	
func on_go_to_animal_pressed():
	SignalBus.move_camera_to.emit(animal_scene.global_position)
	SignalBus.open_popup.emit(animal_scene.cached_global_position, animal_scene)
	return
