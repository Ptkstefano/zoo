extends MarginContainer

@export var level_star : Texture
@export var level_star_half : Texture

var star_instances

func _ready():
	SignalBus.money_changed.connect(on_money_changed)
	%ScoreButton.pressed.connect(on_score_button)
	ZooManager.zoo_reputation_updated.connect(on_reputation_update)
	ZooManager.peep_count_updated.connect(on_peep_count_update)
	star_instances = %UI_ReputationStars.get_children()
	on_reputation_update(ZooManager.reputation)

func on_money_changed(amount):
	%MoneyLabel.text = "$" + str("%.2f" % amount)

func on_score_button():
	SignalBus.open_box.emit(IdRefs.UI_BOXES.MANAGEMENT)

	
func on_reputation_update(reputation):
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

func on_peep_count_update(value):
	%PeepCountLabel.text = str(value)
