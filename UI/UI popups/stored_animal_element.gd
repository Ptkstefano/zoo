extends PanelContainer

var stored_animal : StoredAnimal

var female_icon = load("res://UI/Icons/gendericon_female.png")
var male_icon = load("res://UI/Icons/gendericon_male.png")

signal place_animal
signal release_animal

func _ready() -> void:
	if !stored_animal:
		return
	
	%AnimalIcon.texture = stored_animal.animal_res.icon
	if stored_animal.animal_gender == IdRefs.ANIMAL_GENDERS.FEMALE:
		%GenderIcon.texture = female_icon
	else:
		%GenderIcon.texture = male_icon
	%AnimalSpecies.text = tr(stored_animal.animal_res.tr_name)
	%AnimalAge.text = Helpers.format_months_to_years_and_months(stored_animal.months_of_life)
	%ReleaseAnimalButton.pressed.connect(release_animal.emit.bind(stored_animal))
	%PlaceAnimalButton.pressed.connect(place_animal.emit.bind(stored_animal))
