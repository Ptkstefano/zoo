extends Node2D
class_name FixtureDecoration

var fixture_res : fixture_resource

var placement_global_pos : Vector2

var direction : int
var cell : Vector2i

var type : IdRefs.FIXTURE_TYPES

var sitting_posisitions = []

var lights = []

var is_available : bool = true

signal remove_fixture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type = fixture_res.type
	for children in get_children():
		if int(children.name) != direction:
			children.queue_free()
		else:
			children.get_node('FixtureArea').area_entered.connect(on_area_entered)
			for children2 in children.get_children():
				if children2 is Sprite2D:
					children2.texture = fixture_res.texture
				if children2 is PointLight2D:
					if type != IdRefs.FIXTURE_TYPES.LIGHT:
						children2.queue_free()
					else:
						SignalBus.start_night.connect(on_start_night)
						SignalBus.start_day.connect(on_start_day)
						lights.append(children2)
						children2.hide()
	z_index = Helpers.get_current_tile_z_index(global_position)
	

func on_area_entered(area):
	if area is Bulldozer:
		remove_fixture.emit(self)

func on_start_night():
	for light in lights:
		light.show()
	
func on_start_day():
	for light in lights:
		light.hide()
