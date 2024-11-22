extends Resource

class_name animal_resource

@export_group("Animal settings")

@export var name : String
@export var species_id : IdRefs.ANIMAL_SPECIES
@export var cost : float
@export var texture : Texture2D
@export var thumb : Texture2D
@export var feed : IdRefs.FEED_TYPES

@export var shadow_scale : float = 1
@export var sprite_y_offset : int = 0

@export var animation_speed_scale : float

@export_group("Animal behavior")
@export var base_speed : float
@export var run_speed : float

@export var can_swim : bool
@export var minimum_shelter_level : int

@export var animal_rating : int


@export_group("Animal preferences")
## Expresses minimum needed percentage of terrain types
# 0-grass
# 1-sand
# 2-dirt
# 3-deciduous
# 4-savanna
@export var terrain_preference : Dictionary
@export var terrain_dislike : Array[int]
@export var needs_water : bool
@export var minimum_habitat_size: int
@export var minimum_vegetation_coverage : float
@export var maximum_vegetation_coverage : float
@export var minimum_herd_size : int
@export var maximum_herd_density : float
