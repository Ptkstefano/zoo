extends Node2D

class_name AnimalFeed

var food_available : bool = true

var amount : float = 100:
	set(value):
		amount = clamp(amount, 0, 100)
		set_sprite()

func eat(value):
	amount -= value
	
func set_sprite():
	if amount > 50:
		$Sprite2D.frame = 0
	elif amount > 2:
		$Sprite2D.frame = 1
	else:
		$Sprite2D.frame = 2
		feed_empty()
		
func feed_empty():
	food_available = false
	await get_tree().create_timer(15).timeout
	if amount < 10:
		queue_free()

func fill():
	amount = 100
