extends Node2D

class_name AnimalFeed

var food_available : bool = true

var base_x : int = 0

var amount : float = 100:
	set(value):
		amount = clamp(value, 0, 100)
		set_sprite()

func _ready() -> void:
	$Sprite2D.frame = base_x

func eat(value):
	amount -= value
	
func set_sprite():
	if amount > 50:
		$Sprite2D.frame = base_x + 0
	elif amount > 2:
		$Sprite2D.frame = base_x + 1
	else:
		$Sprite2D.frame = base_x + 2
		feed_empty()
		
func feed_empty():
	food_available = false
	await get_tree().create_timer(15).timeout
	if amount < 10:
		queue_free()

func fill():
	amount = 100
