extends PanelContainer

var stored_animal : StoredAnimal

var female_icon = load("res://UI/Icons/gendericon_female.png")
var male_icon = load("res://UI/Icons/gendericon_male.png")

signal place_animal
signal element_selected

func _ready() -> void:
	if !stored_animal:
		return
		
	gui_input.connect(on_gui_input)
	
	%AnimalIcon.texture = stored_animal.animal_res.icon
	if stored_animal.animal_gender == IdRefs.ANIMAL_GENDERS.FEMALE:
		%GenderIcon.texture = female_icon
	else:
		%GenderIcon.texture = male_icon
	%AnimalSpecies.text = tr(stored_animal.animal_res.tr_name)
	#%AnimalAge.text = Helpers.format_months_to_years_and_months(stored_animal.months_of_life)
	#%ReleaseAnimalButton.pressed.connect(release_animal.emit.bind(stored_animal))
	#%PlaceAnimalButton.pressed.connect(place_animal.emit.bind(stored_animal))

func on_gui_input(event):
	if event is InputEventScreenTouch and event.pressed:
		selected()

func selected():
	place_animal.emit(stored_animal)
	element_selected.emit(stored_animal.id)
	self_modulate = Color('#8bfb5f')
	#scale = Vector2(1.1,1.1)
	
func deselect():
	self_modulate = Color.WHITE
	#scale = Vector2.ONE
