extends TileMapLayer

var highlighted = []
var default_transparency = '50'
var default_color = ('#df9b40')
var bulldozer_color = ('#bc5042')


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color(default_color+default_transparency)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_highlight(list_of_coordinates, is_bulldozing):
	clear_highlight()
	if is_bulldozing:
		modulate = Color(bulldozer_color+default_transparency)
	else:
		modulate = Color(default_color+default_transparency)
	for tile_coordinate in list_of_coordinates:
		if tile_coordinate not in highlighted:
			highlighted.append(tile_coordinate)
		set_cell(tile_coordinate, 0, Vector2(0,0))
		
func clear_highlight():
	for coord in highlighted:
		set_cell(coord, -1)
	highlighted.clear()
		
