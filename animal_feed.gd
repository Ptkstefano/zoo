extends Node2D

class_name AnimalFeed

var food_available : bool = true

var sprite_y : int = 0

var pos_x
var pos_y

var feed_cost = 200

var amount : float = 100:
	set(value):
		amount = clamp(value, 0, 100)
		set_sprite()

func _ready() -> void:
	z_index = Helpers.get_current_tile_z_index(global_position)
	$Sprite2D.frame_coords = Vector2(0, sprite_y)
	pos_x = global_position.x
	pos_y = global_position.y
	pay_for_feed(feed_cost)

func eat(value):
	amount -= value
	
func set_sprite():
	if amount > 50:
		$Sprite2D.frame_coords = Vector2(0, sprite_y)
	elif amount > 2:
		$Sprite2D.frame_coords = Vector2(1, sprite_y)
	else:
		$Sprite2D.frame_coords = Vector2(2, sprite_y)
		feed_empty()
		
func feed_empty():
	food_available = false
	if !get_tree():
		return
	await get_tree().create_timer(15).timeout
	if amount < 10:
		queue_free()

func fill():
	#if base_x == IdRefs.FEED_TYPES.HERBIVORE:
		
	#elif base_x == IdRefs.FEED_TYPES.MEAT:
		
	#elif
	var remaining_multiplier = ((100 - amount) * 0.01)
	pay_for_feed(feed_cost * remaining_multiplier)
	amount = 100

func pay_for_feed(amount):
	FinanceManager.remove(amount, IdRefs.PAYMENT_REMOVE_TYPES.FEED)
	SignalBus.money_tooltip.emit(amount, false, global_position)
