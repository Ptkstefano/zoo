extends HBoxContainer

@export var level_star : PackedScene
@export var level_star_half : PackedScene

func _ready():
	ZooManager.zoo_reputation_updated.connect(on_reputation_update)
	
func on_reputation_update(reputation):
	for child in get_children():
		child.queue_free()
	
	var rounded = round(reputation * 2) * 0.5
	
	var full_stars = floor(rounded)
	var has_half_star = (rounded - full_stars) > 0

	# Step 3: Build the star string
	for star in full_stars:
		add_child(level_star.instantiate())
	if has_half_star:
		add_child(level_star_half.instantiate())
