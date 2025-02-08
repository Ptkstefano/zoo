extends Node2D

class_name SceneryVegetation

var type = IdRefs.SCENERY_TYPES.VEGETATION

var vegetation_res : vegetation_resource
var vegetation_weight

var random_y : int

var cached_position : Vector2

var id : int

signal object_removed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area.area_entered.connect(on_area_entered)
	$Sprite2D.frame_coords=Vector2(vegetation_res.atlas_x, random_y)
	z_index = Helpers.get_current_tile_z_index(global_position)
	vegetation_weight = vegetation_res.vegetation_weight
	Effects.wobble(self)
	cached_position = global_position
	#$Timer.timeout.connect(on_vegetation_move)

func on_area_entered(area):
	if area is Bulldozer:
		$Area/CollisionShape2D.disabled = true
		object_removed.emit(self)

func on_vegetation_move():
	var tween = get_tree().create_tween()
	tween.tween_property(self, 'scale', Vector2(randf_range(0.9,1.1), randf_range(0.9,1.1)), 2)
