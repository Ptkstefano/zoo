extends Node2D

## Every staff character is composed of a main staff_scene and a child profession scene
@export var staff_scene : PackedScene

@export var keeper_behavior : PackedScene

@export var keeper_sprite : Texture
@export var keeper_unique_sprite : Texture

func _ready():
	SignalBus.hire_staff.connect(on_hire_staff)
	spawn_staff(IdRefs.STAFF_TYPES.ZOOKEEPER_UNIQUE, null)


func on_hire_staff(staff_type):
	spawn_staff(staff_type, null)

func spawn_staff(staff_type : IdRefs.STAFF_TYPES, data):
	var staff = staff_scene.instantiate() as Staff
	staff.staff_type = staff_type
	staff.global_position = Vector2(-1270, 655)
	staff.id = ZooManager.generate_staff_id()
	if staff_type == IdRefs.STAFF_TYPES.ZOOKEEPER_UNIQUE:
		staff.set_sprite(keeper_unique_sprite)
		var behavior_node = keeper_behavior.instantiate()
		staff.staff_behavior = behavior_node
		staff.add_child(behavior_node)
	if staff_type == IdRefs.STAFF_TYPES.ZOOKEEPER:
		staff.set_sprite(keeper_sprite)
		staff.salary = 1200
		var behavior_node = keeper_behavior.instantiate()
		staff.staff_behavior = behavior_node
		staff.add_child(behavior_node)
		
	add_child(staff)
	ZooManager.add_staff(staff_type, staff)
		
