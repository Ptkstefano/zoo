extends StaticBody2D


var tree_res : tree_resource

var vegetation_weight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RemovalArea.area_entered.connect(on_removal)
	$Sprite2D.texture = tree_res.texture
	$Sprite2D.offset = tree_res.texture_offset
	z_index = Helpers.get_current_tile_z_index(global_position)
	vegetation_weight = tree_res.vegetation_weight


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_removal(bulldozer):
	$RemovalArea/CollisionShape2D.disabled = true
	queue_free()
