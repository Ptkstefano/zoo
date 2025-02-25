extends PanelContainer

var review

@export var level_star : Texture
@export var level_star_half : Texture

func _ready() -> void:
	for thought in review['thoughts']:
		var thought_label = Label.new()
		thought_label.text = tr(ThoughtManager.peep_thoughts[int(thought)].description)
		%ThoughtList.add_child(thought_label)
		if ThoughtManager.peep_thoughts[int(thought)].is_positive:
			thought_label.add_theme_color_override("font_color", ColorRefs.positive_green)
		else:
			thought_label.add_theme_color_override("font_color", ColorRefs.negative_red)

	var reputation = review['rating']
	var star_instances = %UI_ReputationStars.get_children()

	var rounded = round(reputation * 2) * 0.5
	
	var full_stars = int(floor(rounded))
	var has_half_star = (rounded - full_stars) > 0

	for i in range(5):
		star_instances[i].custom_minimum_size = Vector2(76, 72)
		if i + 1 <= full_stars:
			star_instances[i].texture = level_star
		else:
			if i == full_stars and has_half_star:
				star_instances[i].texture = level_star_half
			else:
				star_instances[i].texture = null
				star_instances[i].custom_minimum_size = Vector2.ZERO
