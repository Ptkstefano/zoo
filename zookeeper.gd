extends Node

class_name ZooKeeper

enum zookeeper_states {STOPPED, WALKING, RESTING, GOING_TO_ENCLOSURE, LEAVING_ENCLOSURE, FEEDING, MOVING_TOWARDS_DEAD_ANIMAL}
var current_state = zookeeper_states.STOPPED

var destination_enclosure : Enclosure

var is_inside_enclosure : bool = false

signal destination_updated
signal leap_towards


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
		$StateTimer.start()
	if state == zookeeper_states.FEEDING:
		feed_enclosure()
	if state == zookeeper_states.MOVING_TOWARDS_DEAD_ANIMAL:
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
	
	## TODO - Get a signal if enclosure is removed to prevent crash
	var enclosure_amount = ZooManager.enclosures_needing_work.keys().size()
	if enclosure_amount < 1:
		change_state(zookeeper_states.STOPPED)
		return
		
	var i = 0
	while true:
		
		if i > enclosure_amount * 2:
			change_state(zookeeper_states.STOPPED)
			break
			
		## TODO - Sort this
		destination_enclosure = ZooManager.enclosures_needing_work[ZooManager.enclosures_needing_work.keys().front()]
	
		if !destination_enclosure.entrance_cell:
			ZooManager.enclosures_needing_work.erase(destination_enclosure.id)
			continue
		
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
	ZooManager.enclosures_needing_work.erase(destination_enclosure.id)
	leap_towards.emit(TileMapRef.map_to_local(destination_enclosure.entrance_cell), false)
	destination_enclosure.open_door()
	await get_tree().create_timer(2).timeout
	is_inside_enclosure = false
	destination_enclosure = null
	change_state(zookeeper_states.STOPPED)

func target_unreacheable():
	change_state(zookeeper_states.STOPPED)

func check_for_enclosure_work():
	if destination_enclosure.animal_feed:
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
