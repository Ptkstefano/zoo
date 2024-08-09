extends TileMapLayer

var highlighted = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_highlight(coords):
	clear_highlight()
	for coord in coords:
		if coord not in highlighted:
			highlighted.append(coord)
		set_cell(coord, 0, Vector2(0,0))
		
func clear_highlight():
	for coord in highlighted:
		highlighted.erase(coord)
		set_cell(coord, -1)
