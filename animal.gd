extends CharacterBody2D


const SPEED = 20.0
const JUMP_VELOCITY = -400.0

var area : area

var agent: NavigationAgent2D

func _ready() -> void:
	agent = $NavigationAgent2D
	agent.set_target_position(get_new_destination())

func _physics_process(delta: float) -> void:
	if velocity.x > 0:
		$Sprite2D.flip_h=true
	else:
		$Sprite2D.flip_h=false
	if velocity.y > 0:
		$AnimationPlayer.play('Walk_S')
	else:
		$AnimationPlayer.play('Walk_N')
	if agent.is_navigation_finished():
		print('arrived')
		agent.target_position=get_new_destination()
	else:
		velocity = (agent.get_next_path_position() - global_position).normalized() * SPEED
		print(velocity)
		move_and_slide()
		
func get_new_destination():
	return area.generate_animal_destination()
