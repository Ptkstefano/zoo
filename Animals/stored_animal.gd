extends Resource
class_name StoredAnimal

var id: int
var x_pos: float
var y_pos: float
var animal_res: animal_resource
var needs_rest: float = 70
var needs_hunger: float = 70
var needs_play: float = 70
var animal_gender: IdRefs.ANIMAL_GENDERS
var is_animal_pregnant: bool = false
var months_pregnant: int = 0
var is_looking_for_mate: bool = false
var is_infant: bool = false
var animal_color_variation: int = 0
var months_of_life: int
var months_in_zoo: int = 0
var is_inside_shelter: bool = false

func get_saved_data() -> Dictionary:
	return {
		"id": id,
		"x_pos": x_pos,
		"y_pos": y_pos,
		"animal_res": animal_res.get_path(),
		"needs_rest": needs_rest,
		"needs_hunger": needs_hunger,
		"needs_play": needs_play,
		"animal_gender": animal_gender,
		"is_animal_pregnant": is_animal_pregnant,
		"months_pregnant": months_pregnant,
		"is_looking_for_mate": is_looking_for_mate,
		"is_infant": is_infant,
		"animal_color_variation": animal_color_variation,
		"months_of_life": months_of_life,
		"months_in_zoo": months_in_zoo,
		"is_inside_shelter": is_inside_shelter
	}

func restore_save_data(data: Dictionary) -> void:
	id = data["id"]
	x_pos = data["x_pos"]
	y_pos = data["y_pos"]
	animal_res = load(data["animal_res"])
	needs_rest = data["needs_rest"]
	needs_hunger = data["needs_hunger"]
	needs_play = data["needs_play"]
	animal_gender = data["animal_gender"]
	is_animal_pregnant = data["is_animal_pregnant"]
	months_pregnant = data["months_pregnant"]
	is_looking_for_mate = data["is_looking_for_mate"]
	is_infant = data["is_infant"]
	animal_color_variation = data["animal_color_variation"]
	months_of_life = data["months_of_life"]
	months_in_zoo = data["months_in_zoo"]
	is_inside_shelter = data["is_inside_shelter"]

func create_new_animal(data: Dictionary) -> void:
	id = data["id"]
	animal_res = data["animal_res"]
	animal_gender = data["animal_gender"]
	animal_color_variation = data["animal_color_variation"]
	months_of_life = data["months_of_life"]
