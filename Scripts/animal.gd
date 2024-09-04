extends CharacterBody2D

var animal_res

var speed = 20.0

enum ANIMAL_STATES {IDLE, MOVING, EATING}
var animal_state = ANIMAL_STATES.MOVING

var area : area

var agent: NavigationAgent2D

signal animal_removed

func _ready() -> void:
	agent = $NavigationAgent2D
	$StateTimer.timeout.connect(on_state_timer_timeout)
	agent.set_target_position(get_new_destination())
	$AnimationPlayer.speed_scale = 0.5

func initialize_animal(animal_res, coordinate, found_area):
	$Sprite2D.texture = animal_res.texture
	speed = animal_res.speed
	## Corrects the y-sort position of the animal
	$Sprite2D.offset = Vector2(0, (-($Sprite2D.texture.get_height() * 0.25) + 4))
	
	animal_res = animal_res
	global_position = coordinate
	area = found_area

func _physics_process(delta: float) -> void:
	z_index = Helpers.get_current_tile_z_index(global_position)
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
			velocity = (agent.get_next_path_position() - global_position).normalized() * speed
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

func remove_animal():
	animal_removed.emit()
	queue_free()
