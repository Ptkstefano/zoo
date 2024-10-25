extends Node2D
class_name Fixture

var fixture_res : fixture_resource

var fixture_directions : Array
var cell

var type = NameRefs.FIXTURES.BENCH

var available_fixtures : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for children in $Directions.get_children():
		children.visible = false
		if children.name in fixture_directions:
			children.visible = true
			children.find_child(children.name).texture = fixture_res.texture
			available_fixtures[children.name] = {'dir': children.name, 'available': true, 'p1': children.get_node('p1').global_position, 'p2': children.get_node('p2').global_position}
	z_index = Helpers.get_current_tile_z_index(global_position)

func get_available():
	for key in available_fixtures.keys():
		var fixture = available_fixtures[key]
		if fixture['available']:
			fixture['available'] = false
			return fixture

## Called by peep group once fixture usage is done
func make_available(fixture):
	fixture['available'] = true
