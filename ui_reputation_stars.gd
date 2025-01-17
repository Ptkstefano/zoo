extends HBoxContainer

@export var level_star : Texture
@export var level_star_half : Texture

var star_instances

func _ready():
	ZooManager.zoo_reputation_updated.connect(on_reputation_update)
	star_instances = get_children()
	
func on_reputation_update(reputation):
	print('REPUTATION UPDATE')
	var rounded = round(reputation * 2) * 0.5
	
	var full_stars = int(floor(rounded))
	var has_half_star = (rounded - full_stars) > 0

	# Step 3: Build the star string
	for i in range(5):
		if i + 1 <= full_stars:
			star_instances[i].texture = level_star
		else:
			if i == full_stars and has_half_star:
				star_instances[i].texture = level_star_half
			else:
				star_instances[i].texture = null
			
