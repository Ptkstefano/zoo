extends Node2D

class_name SceneryDecoration

var type = IdRefs.SCENERY_TYPES.DECORATION

var category = 'decoration'

var decoration_res : decoration_resource

signal removed

var id : int

var cached_position : Vector2
var direction : IdRefs.DIRECTIONS = IdRefs.DIRECTIONS.S

var cell : Vector2

func _ready() -> void:
	$RemovalArea.area_entered.connect(on_removal)
	$Sprite2D.texture = decoration_res.texture
	$Sprite2D.offset = decoration_res.texture_offset
	z_index = Helpers.get_current_tile_z_index(global_position)
	cached_position = global_position
	if direction == IdRefs.DIRECTIONS.E:
		$Sprite2D.flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_removal(bulldozer):
	removed.emit(cell)
	queue_free()
