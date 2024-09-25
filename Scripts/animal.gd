extends CharacterBody2D

var animal_res

var speed = 20.0

enum ANIMAL_STATES {IDLE, MOVING, EATING}
var animal_state = ANIMAL_STATES.MOVING

var enclosure : Enclosure

var agent: NavigationAgent2D

var is_swimming : bool = false

signal animal_removed

func _ready() -> void:
	agent = $NavigationAgent2D
	$StateTimer.timeout.connect(on_state_timer_timeout)
	agent.set_target_position(get_new_destination())
	$AnimationPlayer.speed_scale = 1.5
	$SwimDetection
	$SwimDetection.area_entered.connect(on_swim_start)
	$SwimDetection.area_exited.connect(on_swim_stop)

func initialize_animal(animal_res, coordinate, found_enclosure):
	$Sprite2D.texture = animal_res.texture
	speed = animal_res.speed
	## Corrects the y-sort position of the animal
	$Sprite2D.offset = Vector2(0, (-($Sprite2D.texture.get_height() * 0.25) + 4))
	
	#if animal_res.can_swim:
		#$NavigationAgent2D.navigation_layers = 3
	
	animal_res = animal_res
	global_position = coordinate
	enclosure = found_enclosure
	print(enclosure)

func _physics_process(delta: float) -> void:
	z_index = Helpers.get_current_tile_z_index(global_position)
	if animal_state == ANIMAL_STATES.MOVING:
		if velocity.x > 0:
			$Sprite2D.flip_h=true
		else:
			$Sprite2D.flip_h=false
		if velocity.y > 0:
			if is_swimming:
				$AnimationPlayer.play('Swim_S')
			else:
				$AnimationPlayer.play('Walk_S')
		elif velocity.y < 0:
			if is_swimming:
				$AnimationPlayer.play('Swim_N')
			else:
				$AnimationPlayer.play('Walk_N')
		if agent.is_navigation_finished():
			change_state()
		else:
			velocity = (agent.get_next_path_position() - global_position).normalized() * speed
			move_and_slide()
		
func get_new_destination():
	return TileMapRef.map_to_local(enclosure.enclosure_cells.pick_random())

func on_state_timer_timeout():
	agent.target_position=get_new_destination()
	animal_state = ANIMAL_STATES.MOVING
	
func change_state():
	$StateTimer.start()
	if is_swimming:
		agent.target_position=get_new_destination()
		return
	if randi_range(0, 100) > 50:
		animal_state = ANIMAL_STATES.IDLE
		$AnimationPlayer.play('Idle')
	else:
		animal_state = ANIMAL_STATES.EATING
		$AnimationPlayer.play('Eat')

func remove_animal():
	animal_removed.emit()
	queue_free()

func on_swim_start(area):
	is_swimming = true
	
func on_swim_stop(area):
	is_swimming = false
