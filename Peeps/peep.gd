extends CharacterBody2D


const SPEED = 20.0

@export var head_sprites_m : Array[Texture2D]
@export var body_sprites_m : Array[Texture2D]

@export var head_sprites_f : Array[Texture2D]
@export var body_sprites_f : Array[Texture2D]

var genders = ['m', 'f']
var peep_gender

enum PEEP_STATES {IDLE, MOVING}
var peep_state = PEEP_STATES.MOVING

var peep_manager : PeepManager

var agent: NavigationAgent2D

var position_offset : Vector2
var group_position : Vector2

var body_texture
var head_texture

var frame = 0

func _ready() -> void:
	$FrameTimer.timeout.connect(on_frame_timer)
	peep_gender = genders.pick_random()
	#set_peep_visuals()
	#$AnimationPlayer.speed_scale = randf_range(0.9, 1.1)

func _physics_process(delta: float) -> void:
	z_index = Helpers.get_current_tile_z_index(global_position)
	if peep_state == PEEP_STATES.MOVING:
		if velocity.x > 0:
			$BodyParts/Head.flip_h=true
			$BodyParts/Body.flip_h=true
		else:
			$BodyParts/Head.flip_h=false
			$BodyParts/Body.flip_h=false
		if velocity.y > 0:
			$AnimationPlayer.play('Walk_S')
		elif velocity.y < 0:
			$AnimationPlayer.play('Walk_N')
		elif velocity == Vector2.ZERO:
			$AnimationPlayer.play('Idle')
		velocity = ((group_position + position_offset) - global_position).normalized() * SPEED
		#global_position = group_position + position_offset
		move_and_slide()
		
func on_frame_timer():
	if frame == 0:
		frame = 1
	else:
		frame = 0
		
func set_peep_visuals():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://Peeps/peep.gdshader") 
	
	if peep_gender == 'm':
		body_texture =  body_sprites_m.pick_random()
		head_texture = head_sprites_m.pick_random()
		#$BodyParts/Head.texture =
		#$BodyParts/Body.texture = 
	else:
		body_texture = body_sprites_f.pick_random()
		head_texture = head_sprites_f.pick_random()
		#$BodyParts/Head.texture = head_sprites_f.pick_random()
		#$BodyParts/Body.texture = body_sprites_f.pick_random()
	
	shader_material.set_shader_parameter("body_color", ColorRefs.body_colors.pick_random())
	shader_material.set_shader_parameter("skin_color", ColorRefs.skin_colors.pick_random())
	shader_material.set_shader_parameter("hair_color", ColorRefs.hair_colors.pick_random())
	
	$BodyParts/Body.material = shader_material
	$BodyParts/Head.material = shader_material
		
func get_new_destination():
	return peep_manager.generate_peep_destination()

func on_state_timer_timeout():
	agent.target_position=get_new_destination()
	peep_state = PEEP_STATES.MOVING
	
func change_state():
	$StateTimer.start()
	peep_state = PEEP_STATES.IDLE
	$AnimationPlayer.play('Idle')

	
