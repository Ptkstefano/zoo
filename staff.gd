extends Node2D

var speed = 25

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var peepSprite = $PeepSprite

var direction : Vector2

var frame = 0
var sprite_x := 0
var sprite_y := 0

var staff_class

var is_moving : bool = false

func _ready():
	agent.waypoint_reached.connect(on_agent_waypoint_reached)
	$FrameTimer.timeout.connect(on_frame_timer)
	staff_class = $Zookeeper
	staff_class.destination_updated.connect(on_destination_update)
	if staff_class is ZooKeeper:
		staff_class.leap_towards.connect(on_leap_towards)
	

func _process(delta: float) -> void:
	z_index = Helpers.get_current_tile_z_index(global_position) + 1
	
	if is_moving:
		move_toward_direction(direction, delta)
		
		if agent.is_navigation_finished():
			on_agent_target_reached()
			
		update_sprite_direction()
		
	
	peepSprite.frame_coords = Vector2(sprite_x + frame, sprite_y)
	
func move_toward_direction(direction: Vector2, delta: float):
	global_position += direction * speed * delta
	
func on_agent_waypoint_reached(d):
	await get_tree().create_timer(0.05).timeout
	direction = (agent.get_next_path_position() - global_position).normalized()
	
func on_frame_timer():
	if frame == 0:
		frame = 1
	else:
		frame = 0

func on_agent_target_reached():
	is_moving = false
	sprite_x = 0
	staff_class.destination_reached()

func on_destination_update(destination):
	is_moving = true
	agent.target_position = destination

func on_leap_towards(final_pos, entering_enclosure):
	## Used so that zookeepers can bridge the gap between paths and enclosure
	if entering_enclosure:
		var tween = get_tree().create_tween()
		sprite_x = 2
		direction = global_position.direction_to(final_pos)
		update_sprite_direction()
		tween.tween_property(self, "global_position", final_pos, 2).set_trans(Tween.TRANS_LINEAR)
		await get_tree().create_timer(2).timeout
		$NavigationAgent2D.set_navigation_layer_value(1, false)
		$NavigationAgent2D.set_navigation_layer_value(2, true)
		sprite_x = 0
	else:		
		var tween = get_tree().create_tween()
		sprite_x = 2
		direction = global_position.direction_to(final_pos)
		update_sprite_direction()
		tween.tween_property(self, "global_position", final_pos, 2).set_trans(Tween.TRANS_LINEAR)
		await get_tree().create_timer(2).timeout
		$NavigationAgent2D.set_navigation_layer_value(1, true)
		$NavigationAgent2D.set_navigation_layer_value(2, false)
		sprite_x = 0
	
func update_sprite_direction():
	if direction.x > 0:
		sprite_x = 2
		peepSprite.flip_h=true
	else:
		sprite_x = 2
		peepSprite.flip_h=false
		
	if direction.y > 0:
		sprite_y = 1
	elif direction.y < 0:
		sprite_y = 0
