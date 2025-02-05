extends PanelContainer

var staff_scene : Staff



func _ready():
	if staff_scene.staff_type == IdRefs.STAFF_TYPES.ZOOKEEPER_UNIQUE:
		%StaffName.text = 'Zookeeper Janet'
	if staff_scene.staff_type == IdRefs.STAFF_TYPES.ZOOKEEPER:
		%StaffName.text = 'Zookeeper #' + str(staff_scene.id)
		
	%SalaryLabel.text = 'Salary: TODO'
	%GoToStaffButton.pressed.connect(on_go_to_staff)
	
func set_icon(icon : Texture):
	%Icon.texture = icon

func on_go_to_staff():
	SignalBus.move_camera_to.emit(staff_scene.global_position)
