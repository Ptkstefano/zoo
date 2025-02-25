class_name PeepThought
var description: String
var point_value: float
var is_positive: bool
var bubble_frame : int

func _init(description, point_value, is_positive, bubble_frame):
	self.description = description
	self.point_value = point_value
	self.is_positive = is_positive
	self.bubble_frame = bubble_frame
