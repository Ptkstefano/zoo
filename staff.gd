extends Node2D

var speed = 25

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var peepSprite = $PeepSprite

var direction : Vector2

var frame = 0
var sprite_x := 0
var sprite_y := 0

func _ready():
	agent.waypoint_reached.connect(on_agent_waypoint_reached)
	$FrameTimer.timeout.connect(on_frame_timer)
	agent.target_position = on_agent_target_reached()
	

func _process(delta: float) -> void:
	z_index = Helpers.get_current_tile_z_index(global_position) + 1
	move_toward_direction(direction, delta)
	
	if agent.is_navigation_finished():
		agent.target_position = on_agent_target_reached()
		
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
	var path_manager = get_tree().get_first_node_in_group("PathManager")
	return path_manager.generate_peep_destination()
