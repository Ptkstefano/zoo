extends CharacterBody2D


const SPEED = 20.0
const JUMP_VELOCITY = -400.0

enum PEEP_STATES {IDLE, MOVING}
var peep_state = PEEP_STATES.MOVING

var peep_manager : PeepManager

var agent: NavigationAgent2D

func _ready() -> void:
	agent = $NavigationAgent2D
	$StateTimer.timeout.connect(on_state_timer_timeout)
	agent.set_target_position(get_new_destination())

func _physics_process(delta: float) -> void:
	z_index = Helpers.get_current_tile_z_index(global_position)
	if peep_state == PEEP_STATES.MOVING:
		if velocity.x > 0:
			$Sprite2D.flip_h=true
		else:
			$Sprite2D.flip_h=false
		if velocity.y > 0:
			$AnimationPlayer.play('Walk_S')
		elif velocity.y < 0:
			$AnimationPlayer.play('Walk_N')
		if agent.is_navigation_finished():
			change_state()
		else:
			velocity = (agent.get_next_path_position() - global_position).normalized() * SPEED
			move_and_slide()
		
func get_new_destination():
	return peep_manager.generate_peep_destination()

func on_state_timer_timeout():
	agent.target_position=get_new_destination()
	peep_state = PEEP_STATES.MOVING
	
func change_state():
	$StateTimer.start()
	peep_state = PEEP_STATES.IDLE
	$AnimationPlayer.play('Idle')
