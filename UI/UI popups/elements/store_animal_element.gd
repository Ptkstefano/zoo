extends PanelContainer

var stored_animal : StoredAnimal

var female_icon = load("res://UI/Icons/gendericon_female.png")
var male_icon = load("res://UI/Icons/gendericon_male.png")

signal buy_animal

func _ready() -> void:
	if !stored_animal:
		return
	
	%AnimalIcon.texture = stored_animal.animal_res.icon
	if stored_animal.animal_gender == IdRefs.ANIMAL_GENDERS.FEMALE:
		%GenderIcon.texture = female_icon
	else:
		%GenderIcon.texture = male_icon
	%AnimalSpecies.text = tr(stored_animal.animal_res.tr_name)
	%BuyButton.pressed.connect(buy_animal_pressed)

func buy_animal_pressed():
	buy_animal.emit(stored_animal)
	%MainContainer.hide()
	%BoughtContainer.show()
