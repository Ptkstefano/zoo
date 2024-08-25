extends CharacterBody2D


const SPEED = 20.0
const JUMP_VELOCITY = -400.0

enum ANIMAL_STATES {IDLE, MOVING, EATING}
var animal_state = ANIMAL_STATES.MOVING

var area : area

var agent: NavigationAgent2D

func _ready() -> void:
	agent = $NavigationAgent2D
	$StateTimer.timeout.connect(on_state_timer_timeout)
	agent.set_target_position(get_new_destination())

func _physics_process(delta: float) -> void:
	if animal_state == ANIMAL_STATES.MOVING:
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
	return area.generate_animal_destination()

func on_state_timer_timeout():
	agent.target_position=get_new_destination()
	animal_state = ANIMAL_STATES.MOVING
	
func change_state():
	$StateTimer.start()
	if randi_range(0, 100) > 50:
		animal_state = ANIMAL_STATES.IDLE
		$AnimationPlayer.play('Idle')
	else:
		animal_state = ANIMAL_STATES.EATING
		$AnimationPlayer.play('Eat')
