extends CanvasLayer

var review_count = {}

@export var review_element : PackedScene

func _ready():
	%CloseButton.pressed.connect(queue_free)
	generate_reviews_tab()
	DataManager.reviews_changed.connect(generate_reviews_tab)

func generate_reviews_tab():
	review_count.clear()
	for child in %ReviewContainer.get_children():
		child.queue_free()
	for modifier in DataManager.modifier_list:
		if modifier in review_count.keys():
			review_count[modifier] += 1
		else:
			review_count[modifier] = 1

	for element in review_count.keys():
		var review_instance = review_element.instantiate()
		review_instance.description = ModifierManager.peep_modifiers[element].description
		review_instance.count = review_count[element]
		review_instance.visible = true
		%ReviewContainer.add_child(review_instance)
