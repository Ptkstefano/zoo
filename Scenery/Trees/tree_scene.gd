extends Node2D

class_name SceneryTree
 
var type = IdRefs.SCENERY_TYPES.TREE

@export var tree_sheet : Texture2D

var tree_res : tree_resource

var texture : Texture2D

var vegetation_weight

var id : int

var cached_position : Vector2

signal object_removed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area.area_entered.connect(on_area_entered)
	$Sprite2D.vframes = tree_sheet.get_height() / 128
	$Sprite2D.hframes = tree_sheet.get_width() / 128
	$Sprite2D.frame_coords = Vector2(tree_res.texture_y, 0)
	texture = tree_sheet
	var y = -128
	var x = -128 * 0.5
	$Sprite2D.offset = Vector2(x,y)
	$Sprite2D.z_index = Helpers.get_current_tile_z_index(global_position)
	vegetation_weight = tree_res.vegetation_weight
	Effects.wobble(self)
	cached_position = global_position
	
	$VisibleOnScreenNotifier2D.screen_entered.connect(on_visibility_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(on_visibility_exited)
	

func on_area_entered(area):
	if area is Bulldozer:
		#$RemovalArea/CollisionShape2D.disabled = true
		if $VisibleOnScreenNotifier2D.is_on_screen():
			SoundscapeManager.trees_in_screen -= 1
		object_removed.emit(self)
		#queue_free()

func on_visibility_entered():
	SoundscapeManager.trees_in_screen += 1
func on_visibility_exited():
	SoundscapeManager.trees_in_screen -= 1
