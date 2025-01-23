extends Camera2D

@export var inputController : InputController

# Variables to keep track of dragging state
var dragging = false
var last_mouse_position = Vector2()

@export var basis_sensitivity = 1.5

@export var min_zoom = Vector2(0.2, 0.2)
@export var max_zoom = Vector2(3.0, 3.0)

var possible_zoom_values = [ 1, 2, 3, 4, 5, 6]
var current_zoom_index = 1
var current_zoom_value = 1

@onready var new_zoom = zoom
@onready var sensitivity = basis_sensitivity

@export var zoom_sensitivity = 0.125

func _ready() -> void:
	inputController.zoom_camera.connect(on_camera_zoom)
	inputController.move_camera.connect(on_camera_move)
	inputController.move_camera_in_direction.connect(on_directional_camera_move)
	

func on_camera_move(mouse_delta):
	var direction = Vector2(-mouse_delta.x * sensitivity, -mouse_delta.y * sensitivity)
	translate(direction)
		
func on_directional_camera_move(move_direction : Vector2):
	var multiplier = 30 
	translate(move_direction * multiplier / zoom)

func _process(delta):
	pass

func on_camera_zoom(direction: int):
	current_zoom_value += direction * 0.05
	current_zoom_value = clamp(current_zoom_value, 0, possible_zoom_values.size() - 1)
	current_zoom_index = roundi(current_zoom_value)
	current_zoom_index = clamp(current_zoom_index, 0, possible_zoom_values.size() - 1)
	var new_zoom = Vector2(possible_zoom_values[current_zoom_index], possible_zoom_values[current_zoom_index])
	new_zoom = new_zoom.clamp(min_zoom, max_zoom)
	var tween = get_tree().create_tween()
	await tween.tween_property(self, "zoom", new_zoom, 0.25).set_trans(Tween.TRANS_SINE)
	sensitivity = basis_sensitivity - (zoom.x * 0.20)
	
