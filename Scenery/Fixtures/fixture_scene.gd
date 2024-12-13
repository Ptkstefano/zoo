extends Node2D
class_name FixtureBench

var fixture_res : fixture_resource

var placement_global_pos : Vector2

var direction : int
var cell

var sitting_posisitions = []

var type = IdRefs.FIXTURES.BENCH

var is_available : bool = true

signal remove_fixture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for children in get_children():
		if int(children.name) != direction:
			children.queue_free()
		else:
			sitting_posisitions.append(children.get_node('p1').global_position)
			sitting_posisitions.append(children.get_node('p2').global_position)
			children.get_node('FixtureArea').area_entered.connect(on_area_entered)
	z_index = Helpers.get_current_tile_z_index(global_position)



func get_available():
	if is_available:
		is_available = false
		return self

## Called by peep group once fixture usage is done
func make_available():
	is_available = true

func on_area_entered(area):
	if area is Bulldozer:
		remove_fixture.emit(self)
