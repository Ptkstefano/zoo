extends Node

class_name ZooKeeper

enum zookeeper_states {STOPPED, WALKING, RESTING, GOING_TO_ENCLOSURE, LEAVING_ENCLOSURE, FEEDING}
var current_state = zookeeper_states.STOPPED

var destination_enclosure : Enclosure

var is_inside_enclosure : bool = false

signal destination_updated
signal leap_towards

func _ready() -> void:
	$StateTimer.timeout.connect(on_state_timer_timeout)
	$StateTimer.start()

func on_state_timer_timeout():
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
	else:
		get_new_task()

func feed_enclosure():
	print('adding feed')
	destination_enclosure.add_animal_feed()
	$StateTimer.start()
	
func get_enclosure_entrance_destination():
	var random_enclosure = ZooManager.zoo_enclosures.keys().pick_random()
	if !random_enclosure:
		change_state(zookeeper_states.STOPPED)
		return
		
	var selected_enclosure = ZooManager.zoo_enclosures[random_enclosure]
	
	if !selected_enclosure.entrance_cell:
		change_state(zookeeper_states.STOPPED)
		return
		
	destination_enclosure = selected_enclosure.node
	var destination = TileMapRef.map_to_local(selected_enclosure.entrance_cell)

	destination_updated.emit(destination)
	change_state(zookeeper_states.GOING_TO_ENCLOSURE)

func get_enclosure_exit_destination():
	var destination = TileMapRef.map_to_local(destination_enclosure.entrance_door_cell)
	destination_updated.emit(destination)


func enter_enclosure():
	leap_towards.emit(TileMapRef.map_to_local(destination_enclosure.entrance_door_cell), true)
	destination_enclosure.open_door()
	await get_tree().create_timer(2).timeout
	is_inside_enclosure = true
	change_state(zookeeper_states.FEEDING)

func leave_enclosure():
	leap_towards.emit(TileMapRef.map_to_local(destination_enclosure.entrance_cell), false)
	destination_enclosure.open_door()
	await get_tree().create_timer(2).timeout
	is_inside_enclosure = false
	destination_enclosure = null
	change_state(zookeeper_states.STOPPED)