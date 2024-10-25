extends CharacterBody2D
class_name Peep


const SPEED = 15.0

@export var sprite_sheet : Texture2D

enum PEEP_STATES {IDLE, MOVING, OBSERVING, RESTING}
var peep_state = PEEP_STATES.MOVING

var peep_manager : PeepManager

var agent: NavigationAgent2D

var position_offset : Vector2
var group_position : Vector2
var target_pos : Vector2

var body_texture
var head_texture

var move_direction : Vector2
var look_direction


var frame := 0
var base_y := 0
var sprite_x := 0
var sprite_y := 0

@onready var peepSprite = $PeepSprite
@onready var screenNotifier = $VisibleOnScreenNotifier2D



func _ready() -> void:
	$FrameTimer.timeout.connect(on_frame_timer)
	set_peep_visuals()
	$FrameTimer.wait_time = randf_range(0.4, 0.55)

func _physics_process(delta: float) -> void:
	if peep_state != PEEP_STATES.RESTING:
		target_pos = (group_position + position_offset)
		
		if global_position.distance_to(target_pos) < 5:
			velocity = Vector2.ZERO
			return
			
		move_direction = global_position.direction_to(target_pos)
		
		if global_position.distance_to(target_pos) > 25:
			velocity = move_direction * SPEED * 2
		else:
			velocity = move_direction * SPEED
		move_and_slide()

func _process(delta: float) -> void:
	if !screenNotifier.is_on_screen():
		return
		
	z_index = Helpers.get_current_tile_z_index(global_position)
	
	if peep_state == PEEP_STATES.MOVING:
		if velocity == Vector2.ZERO:
			sprite_x = 0
		else:
			if velocity.x > 0:
				sprite_x = 2
				peepSprite.flip_h=true
			else:
				sprite_x = 2
				peepSprite.flip_h=false
				
			if velocity.y > 0:
				sprite_y = 1
			elif velocity.y < 0:
				sprite_y = 0
	elif peep_state == PEEP_STATES.OBSERVING:
		if abs(look_direction) > PI * 0.5:
			peepSprite.flip_h = false
		else:
			peepSprite.flip_h = true
			
		if look_direction > 0:
			sprite_y = 1
		else:
			sprite_y = 0
		
	peepSprite.frame_coords = Vector2(sprite_x + frame, sprite_y + base_y)
		
func on_frame_timer():
	if frame == 0:
		frame = 1
	else:
		frame = 0
		
func set_look_direction(dir):
	## Used for sitting in correct direction
	if dir == 'E':
		peepSprite.flip_h = false
		sprite_y = 0
	if dir == 'S':
		peepSprite.flip_h = true
		sprite_y = 0
	if dir == 'W':
		peepSprite.flip_h = true
		sprite_y = 1
	if dir == 'N':
		peepSprite.flip_h = false
		sprite_y = 1
		
func set_peep_visuals():
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://Peeps/peep.gdshader") 
	
	peepSprite.texture = sprite_sheet
	peepSprite.vframes = sprite_sheet.get_height() / 23
	
	base_y = [0, 2].pick_random()
	
	shader_material.set_shader_parameter("body_color", ColorRefs.body_colors.pick_random())
	shader_material.set_shader_parameter("skin_color", ColorRefs.skin_colors.pick_random())
	shader_material.set_shader_parameter("hair_color", ColorRefs.hair_colors.pick_random())
	
	peepSprite.material = shader_material
	
func get_new_destination():
	return peep_manager.generate_peep_destination()

func change_state(state):
	if state == 0: ## Stopped
		peep_state = PEEP_STATES.IDLE
		sprite_x = 0
	if state == 1: ## Walking:
		peep_state = PEEP_STATES.MOVING
		sprite_x = 2
	if state == 2: ## OBSERVING:
		peep_state = PEEP_STATES.OBSERVING
		if randi_range(0,100) > 50:
			sprite_x = 4
		else:
			sprite_x = 0
	if state == 3: ## SITTING:
		peep_state = PEEP_STATES.RESTING
		sprite_x = 6
