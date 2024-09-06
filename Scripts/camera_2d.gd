extends Camera2D

@export var inputController : InputController

# Variables to keep track of dragging state
var dragging = false
var last_mouse_position = Vector2()

@export var basis_sensitivity = 3

@export var min_zoom = Vector2(0.2, 0.2)
@export var max_zoom = Vector2(3.0, 3.0)

@onready var new_zoom = zoom
@onready var sensitivity = basis_sensitivity

@export var zoom_sensitivity = 0.2

func _ready() -> void:
	inputController.zoom_camera.connect(on_camera_zoom)
	inputController.move_camera.connect(on_camera_move)
	

func on_camera_move(mouse_delta):
	var direction = Vector2(-mouse_delta.x * sensitivity, -mouse_delta.y * sensitivity)
	translate(direction)
		

func _process(delta):
	pass

func on_camera_zoom(direction: int):
	var new_zoom = zoom + Vector2(zoom_sensitivity, zoom_sensitivity) * direction
	new_zoom = new_zoom.clamp(min_zoom, max_zoom)
	var tween = get_tree().create_tween()
	await tween.tween_property(self, "zoom", new_zoom, 0.1)
	sensitivity = basis_sensitivity - (zoom.x * 0.5)
