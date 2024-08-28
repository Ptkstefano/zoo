extends TileMapLayer

var highlighted = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_highlight(list_of_coordinates):
	clear_highlight()
	for tile_coordinate in list_of_coordinates:
		if tile_coordinate not in highlighted:
			highlighted.append(tile_coordinate)
		set_cell(tile_coordinate, 0, Vector2(0,0))
		
func clear_highlight():
	for coord in highlighted:
		set_cell(coord, -1)
	highlighted.clear()
		
