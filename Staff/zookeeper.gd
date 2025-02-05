extends Node

class_name StaffZooKeeper

enum zookeeper_states {STOPPED, WALKING, RESTING, GOING_TO_ENCLOSURE, LEAVING_ENCLOSURE, FEEDING, MOVING_TOWARDS_DEAD_ANIMAL}
var current_state = zookeeper_states.STOPPED

var destination_enclosure : Enclosure
var unreacheable_enclosures = []

var is_inside_enclosure : bool = false

signal destination_updated
signal leap_towards
signal stopped
signal reset_staff

@onready var staff_scene = get_parent() ## Parent

func _ready() -> void:
	$StateTimer.timeout.connect(on_state_timer_timeout)
	$StateTimer.start()

func on_state_timer_timeout():
	if is_inside_enclosure:
		check_for_enclosure_work()
		return
	if current_state == zookeeper_states.STOPPED:
		get_new_task()
	if current_state == zookeeper_states.FEEDING:
		change_state(zookeeper_states.LEAVING_ENCLOSURE)
	if current_state == zookeeper_states.RESTING:
		get_new_task()
		
func change_state(state):
	current_state = state
	if state == zookeeper_states.GOING_TO_ENCLOSURE:
		return
	if state == zookeeper_states.LEAVING_ENCLOSURE:
		get_enclosure_exit_destination()
	if state == zookeeper_states.STOPPED:
		stopped.emit()
		$StateTimer.start()
	if state == zookeeper_states.FEEDING:
		feed_enclosure()
	if state == zookeeper_states.MOVING_TOWARDS_DEAD_ANIMAL:
		if is_instance_valid(destination_enclosure.dead_animals.front()):
			destination_updated.emit(destination_enclosure.dead_animals.front().global_position)
	
		
func get_new_task():
	if !destination_enclosure:
		get_enclosure_entrance_destination()
		return
	if current_state == zookeeper_states.GOING_TO_ENCLOSURE:
		## Enter enclosure and start feeding
		enter_enclosure()
		return
	if current_state == zookeeper_states.FEEDING:
		## Finish feeding
		get_new_task()
		return

func destination_reached():
	if current_state == zookeeper_states.LEAVING_ENCLOSURE:
		leave_enclosure()
	if current_state == zookeeper_states.MOVING_TOWARDS_DEAD_ANIMAL:
		remove_dead_animal()
	else:
		get_new_task()

func feed_enclosure():
	destination_enclosure.add_animal_feed()
	change_state(zookeeper_states.STOPPED)
	
func get_enclosure_entrance_destination():
	var enclosure_amount = ZooManager.enclosures_needing_work.size()
	if enclosure_amount < 1:
		change_state(zookeeper_states.STOPPED)
		return

	## TODO - Sort this
	var closest_enclosure_distance : float = 99999
	for enclosure in ZooManager.enclosures_needing_work:
		if enclosure not in unreacheable_enclosures:
			if enclosure.has_zookeeper_assigned:
				continue
			if staff_scene.global_position.distance_to(TileMapRef.map_to_local(enclosure.entrance_cell)) < closest_enclosure_distance:
			## Assign enclosure work to current zookeeper
				destination_enclosure = enclosure
				
	if !destination_enclosure:
		change_state(zookeeper_states.STOPPED)
		return
	else:
		destination_enclosure.has_zookeeper_assigned = true
		destination_enclosure.enclosure_removed.connect(on_destination_enclosure_removed)
		destination_enclosure.enclosure_area_changed.connect(on_destination_enclosure_changed)
		
	if !destination_enclosure.entrance_cell:
		ZooManager.enclosures_needing_work.erase(destination_enclosure.id)
	
	var destination = TileMapRef.map_to_local(destination_enclosure.entrance_cell)
	destination_updated.emit(destination)
	change_state(zookeeper_states.GOING_TO_ENCLOSURE)
	return


func get_enclosure_exit_destination():
	if !is_instance_valid(destination_enclosure):
		change_state(zookeeper_states.STOPPED)
		return
	var destination = TileMapRef.map_to_local(destination_enclosure.entrance_door_cell)
	destination_updated.emit(destination)
		

func enter_enclosure():
	if !is_instance_valid(destination_enclosure.enclosure_fence_manager.entrance_node):
		change_state(zookeeper_states.STOPPED)
	leap_towards.emit(TileMapRef.map_to_local(destination_enclosure.entrance_door_cell), true)
	destination_enclosure.open_door()
	await get_tree().create_timer(2).timeout
	is_inside_enclosure = true
	check_for_enclosure_work()

func leave_enclosure():
	ZooManager.enclosures_needing_work.erase(destination_enclosure)
	destination_enclosure.has_zookeeper_assigned = false
	leap_towards.emit(TileMapRef.map_to_local(destination_enclosure.entrance_cell), false)
	destination_enclosure.open_door()
	await get_tree().create_timer(2).timeout
	is_inside_enclosure = false
	destination_enclosure = null
	change_state(zookeeper_states.STOPPED)
	unreacheable_enclosures.clear()

func target_unreacheable():
	SignalBus.notification.emit('Zookeeper could not find path to enclosure')
	unreacheable_enclosures.append(destination_enclosure)
	destination_enclosure.has_zookeeper_assigned = false
	destination_enclosure = null
	change_state(zookeeper_states.STOPPED)

func check_for_enclosure_work():
	if !is_instance_valid(destination_enclosure):
		reset_staff.emit()
		return
	if destination_enclosure.animal_feed:
		if !is_instance_valid(destination_enclosure.animal_feed):
			if destination_enclosure.animal_feed.amount < 100:
				change_state(zookeeper_states.FEEDING)
			return
	else:
		change_state(zookeeper_states.FEEDING)
		return
	
	if destination_enclosure.dead_animals.size() > 0:
		change_state(zookeeper_states.MOVING_TOWARDS_DEAD_ANIMAL)
	else:
		change_state(zookeeper_states.LEAVING_ENCLOSURE)
		
func remove_dead_animal():
	if destination_enclosure.dead_animals.size() == 0:
		return
	destination_enclosure.dead_animals.front().remove_animal()
	change_state(zookeeper_states.STOPPED)

func on_destination_enclosure_removed():
	reset_staff.emit()

func on_destination_enclosure_changed():
	if is_inside_enclosure:
		reset_staff.emit()

func reset_state():
	destination_enclosure.has_zookeeper_assigned = false
	destination_enclosure = null
	is_inside_enclosure = false
	change_state(zookeeper_states.STOPPED)
	
