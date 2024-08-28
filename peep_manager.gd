extends Node2D

class_name PeepManager

@export var peep_scene : PackedScene
var spawn_location : Vector2

@export var path_manager : PathManager

var peep_count : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_location = path_manager.path_layer.map_to_local(Vector2(0,45))
	$PeepSpawnTimer.timeout.connect(on_peep_spawn_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_peep_spawn_timeout():
	var new_peep = peep_scene.instantiate()
	new_peep.global_position = spawn_location
	new_peep.peep_manager = self
	add_child(new_peep)
	peep_count += 1

func generate_peep_destination():
	return path_manager.generate_peep_destination()
	
