extends Resource
class_name quest_res

@export var id: IdRefs.QUEST_IDS
@export var title: String
@export var introduction_dialogue: Array[String]
@export var closure_dialogue: Array[String]

@export var is_tutorial_quest : bool
@export var is_repeateable : bool

@export var objectives: Dictionary[IdRefs.QUEST_OBJECTIVES, int]

@export var quest_giver : IdRefs.QUEST_GIVERS
@export var rewards: Dictionary[IdRefs.QUEST_REWARDS, int]
@export var prerequisites: Array
