extends Node2D

class_name SceneryVegetation

var type = NameRefs.SCENERY_TYPES.VEGETATION

var vegetation_res : vegetation_resource
var vegetation_weight

var cached_position : Vector2

var texture

signal object_removed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$RemovalArea.area_entered.connect(on_removal)
	$Sprite2D.texture = vegetation_res.texture
	texture = vegetation_res.texture
	var y = -texture.get_height()
	var x = -texture.get_width() * 0.5
	$Sprite2D.offset = Vector2(x,y)
	z_index = Helpers.get_current_tile_z_index(global_position)
	vegetation_weight = vegetation_res.vegetation_weight
	Effects.wobble(self)
	cached_position = global_position
	#await get_tree().create_timer(0.5).timeout
	#$Sprite2D.visible = false


func on_removal(bulldozer):
	$RemovalArea/CollisionShape2D.disabled = true
	object_removed.emit(self)
