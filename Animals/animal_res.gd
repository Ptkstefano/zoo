extends Resource

class_name animal_resource

@export_group("Animal settings")

@export var tr_name : String
@export var id : IdRefs.ANIMAL_SPECIES
@export var rarity : IdRefs.ANIMAL_RARITIES
@export var cost : float
@export var texture : Texture2D
@export var cub_texture : Texture2D
@export var thumbnail : Texture2D
@export var icon : Texture2D
@export var feed : IdRefs.FEED_TYPES

@export var shadow_scale : float = 1
@export var sprite_y_offset : int = 0

@export var animation_speed_scale : float

@export_group("Animal behavior")
@export var base_speed : float
@export var run_speed : float

@export var can_swim : bool

@export var animal_rating : int

@export var months_of_pregnancy : int = 5

@export var percentage_of_will_to_mate : int = 20

@export var months_to_adulthood : int = 12
@export var months_of_expected_lifetime : int = 120


@export_group("Animal preferences")
 ## Expresses a minimum percentage of a given terrain type
@export var terrain_preference : Dictionary[IdRefs.TERRAIN_TYPES, float]
@export var terrain_dislike : Array[IdRefs.TERRAIN_TYPES]
@export var needs_water : bool
@export var minimum_habitat_size: int
## Expresses a minimum number of cells each given animal wants when compared to the herd size
@export var minimum_cells_per_animal : int
## For reference, 1.0 is a value of medium vegetation coverage.
@export var minimum_vegetation_coverage : float
@export var maximum_vegetation_coverage : float
@export var minimum_herd_size : int
@export var favorite_tree : IdRefs.TREE_SPECIES

@export var minimum_shelter_level : int
@export var minimum_fence_level : int

@export_group("Visual settings")

@export var possible_sprite_variations : int = 1
@export var separate_gender_sprites : bool = false
@export var can_be_albino : bool = false
