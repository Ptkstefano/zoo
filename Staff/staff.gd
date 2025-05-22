extends Node2D

class_name Staff

var speed = 25

@onready var agent : NavigationAgent2D = $NavigationAgent2D
@onready var peepSprite = $PeepSprite

@export var quest_giver_icon_scene : PackedScene
var quest_giver_icon : Sprite2D
var is_quest_giver : bool = false
var quest_giver_type : IdRefs.QUEST_GIVERS

var direction : Vector2

var frame = 0
var sprite_x := 0
var sprite_y := 0

var cached_global_position : Vector2

var id : int

var salary : float = 0

var staff_type : IdRefs.STAFF_TYPES

## staff_behavior is a node with staff specific script set by the manager
var staff_behavior

var is_moving : bool = false

var data

signal staff_fired

func _ready():
	agent.waypoint_reached.connect(on_agent_waypoint_reached)
	$FrameTimer.timeout.connect(on_frame_timer)
	staff_behavior.destination_updated.connect(on_destination_update)
	staff_behavior.stopped.connect(on_staff_stopped)
	staff_behavior.reset_staff.connect(reset_staff)
	SignalBus.path_erased.connect(on_path_erased)
	TimeManager.on_pass_month.connect(on_pass_month)
	SignalBus.update_cached_positions.connect(update_cached_position)
	if staff_type == IdRefs.STAFF_TYPES.ZOOKEEPER or staff_type == IdRefs.STAFF_TYPES.ZOOKEEPER_UNIQUE:
		staff_behavior.leap_towards.connect(on_leap_towards)
	
	SignalBus.activate_quest_giver.connect(on_staff_giving_quest)
	
	if data:
		global_position = data['global_position']
		var enclosure = TileMapRef.get_enclosure_by_cell(TileMapRef.local_to_map(global_position))
		if enclosure:
			$NavigationAgent2D.set_navigation_layer_value(1, false)
			$NavigationAgent2D.set_navigation_layer_value(2, true)
			staff_behavior.is_inside_enclosure = true
			

func set_sprite(sprite : Texture):
	$PeepSprite.texture = sprite

func reset_staff():
	global_position = Vector2(-1470, 768)
	$NavigationAgent2D.set_navigation_layer_value(1, true)
	$NavigationAgent2D.set_navigation_layer_value(2, false)
	staff_behavior.reset_state()

func _process(delta: float) -> void:
	z_index = Helpers.get_current_tile_z_index(global_position) + 1
	
	if is_moving:
		if !agent.is_target_reachable():
			staff_behavior.target_unreacheable()
			
			
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
	staff_behavior.destination_reached()

func on_staff_stopped():
	is_moving = false
	sprite_x = 0

func on_destination_update(destination):
	is_moving = true
	agent.target_position = destination

func on_leap_towards(final_pos, is_entering_enclosure):
	## Used so that zookeepers can bridge the gap between paths and enclosure
	if is_entering_enclosure:
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

func on_path_erased(cell):
	if cell == TileMapRef.local_to_map(global_position):
		reset_staff()

func on_pass_month():
	if salary > 0:
		FinanceManager.remove(salary, IdRefs.PAYMENT_REMOVE_TYPES.SALARY)

func update_cached_position():
	cached_global_position.x = global_position.x
	cached_global_position.y = global_position.y

func fire_staff():
	staff_fired.emit(self)

func on_staff_giving_quest(quest_giver : IdRefs.QUEST_GIVERS):
	## TODO - This will only work for unique zookeeper
	if quest_giver == quest_giver_type:
		staff_behavior.start_quest_giver()
		is_quest_giver = true
		quest_giver_icon = quest_giver_icon_scene.instantiate()
		add_child(quest_giver_icon)
		sprite_x = 10
		sprite_y = 1
		peepSprite.flip_h=false
		is_moving = false
	
func on_quest_giver_clicked():
	SignalBus.quest_activated.emit()
	staff_behavior.stop_quest_giver()
	quest_giver_icon.queue_free()
	is_quest_giver = false
	sprite_x = 0

func toggle_pathfinding():
	if $NavigationAgent2D.debug_enabled:
		$NavigationAgent2D.debug_enabled = false
	else:
		$NavigationAgent2D.debug_enabled = true
