extends NavigationRegion2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.peep_navigation_changed.connect(update_navigation_region)


func update_navigation_region():
	bake_navigation_polygon()
	TileMapRef.set_navigation_rid(get_rid())
