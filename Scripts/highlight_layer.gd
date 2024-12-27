extends TileMapLayer

var highlighted = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	SignalBus.clear_highlight.connect(clear_highlight)

func apply_highlight(list_of_coordinates, type : IdRefs.HIGHLIGHT_TYPES):
	clear_highlight()
	print(list_of_coordinates)
	for tile_coordinate in list_of_coordinates:
		if tile_coordinate not in highlighted:
			highlighted.append(tile_coordinate)
		if type == IdRefs.HIGHLIGHT_TYPES.YELLOW:
			set_cell(tile_coordinate, 1, Vector2(0,0))
		elif type == IdRefs.HIGHLIGHT_TYPES.RED:
			set_cell(tile_coordinate, 1, Vector2(1,0))
		elif type == IdRefs.HIGHLIGHT_TYPES.BLUE:
			set_cell(tile_coordinate, 1, Vector2(2,0))
		elif type == IdRefs.HIGHLIGHT_TYPES.BUILDING_E:
			set_cell(tile_coordinate, 1, Vector2(4,0))
		elif type == IdRefs.HIGHLIGHT_TYPES.BUILDING_S:
			set_cell(tile_coordinate, 1, Vector2(5,0))
		elif type == IdRefs.HIGHLIGHT_TYPES.BUILDING_W:
			set_cell(tile_coordinate, 1, Vector2(6,0))
		elif type == IdRefs.HIGHLIGHT_TYPES.BUILDING_N:
			set_cell(tile_coordinate, 1, Vector2(7,0))
		
func clear_highlight():
	for coord in get_used_cells():
		set_cell(coord, -1)
	highlighted.clear()
		
