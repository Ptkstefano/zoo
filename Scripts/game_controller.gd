extends Node2D

@onready var fps_label = %Debug_FPS
@onready var animal_count_label = %Debug_Animals
@onready var mouse_pos_label = %Debug_pos
@onready var mouse_coordinate_label = %Debug_coordinate
@onready var peep_count_label = %Debug_Peeps
@onready var physics_time_label = %Debug_PhysicsTime
@onready var finger_count_label = %Debug_finger
@onready var finger_distance_label = %Debug_distance

@onready var highlight_layer = $"../TileMap/HighlightLayer"

var animal_count = 0:
	set(value):
		animal_count = value
		animal_count_label.text = "Animals: " + str($"../AnimalManager".animal_count)
		
var peep_count = 0:
	set(value):
		peep_count = value
		peep_count_label.text = "Peeps: " + str($"../PeepManager".peep_count)
		
# Called when the node enters the scene tree f1or the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fps_label.text = ("FPS: " + str(Engine.get_frames_per_second()))
	mouse_pos_label.text = str(get_global_mouse_position())
	mouse_coordinate_label.text = str(highlight_layer.local_to_map(get_global_mouse_position()))
	animal_count_label.text = "Animals: " + str($"../Objects/AnimalManager".animal_count)
	peep_count_label.text = "Peeps: " + str($"../Objects/PeepManager".peep_count)
	physics_time_label.text = ("Physics: "+str(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)))
	finger_count_label.text = ("Fingers: "+str($"../InputController".fingers_touching.size()))
	finger_distance_label.text = ("Finger d:"+str($"../InputController".previous_touches_distance))
	
