extends Node2D
class_name FixtureDecoration

var fixture_res : fixture_resource

var placement_global_pos : Vector2

var direction : int
var cell : Vector2i

var type : IdRefs.FIXTURES

var sitting_posisitions = []

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
	z_index = Helpers.get_current_tile_z_index(global_position)

func on_area_entered(area):
	if area is Bulldozer:
		remove_fixture.emit(self)
