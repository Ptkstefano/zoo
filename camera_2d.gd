extends Camera2D


# Variables to keep track of dragging state
var dragging = false
var last_mouse_position = Vector2()

@export var basis_sensitivity = 3

@export var min_zoom = Vector2(0.2, 0.2)
@export var max_zoom = Vector2(3.0, 3.0)

@onready var new_zoom = zoom
@onready var sensitivity = basis_sensitivity
# Mouse sensitivity

@export var zoom_sensitivity = 0.1

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.is_pressed():
				dragging = true
				last_mouse_position = event.position
			else:
				dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_camera(1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_camera(-1)
	elif event is InputEventMouseMotion and dragging:
		var mouse_delta = event.position - last_mouse_position
		# Apply the mouse movement to the camera's position
		translate(Vector2(-mouse_delta.x * sensitivity, -mouse_delta.y * sensitivity))
		
		last_mouse_position = event.position
		

func _process(delta):
	zoom.lerp(new_zoom, 0.01)
	sensitivity = basis_sensitivity - zoom.x
	if dragging:
		# Optionally, additional logic can be added here if needed.
		pass

func _zoom_camera(direction: int):
	# Adjust the zoom level based on mouse wheel direction
	var new_zoom = zoom + Vector2(zoom_sensitivity, zoom_sensitivity) * direction
	# Clamp the zoom level to stay within the min and max zoom
	new_zoom = new_zoom.clamp(min_zoom, max_zoom)
	zoom = new_zoom
