extends Resource
class_name Quest

@export var quest_id: int
@export var title: String
@export var introduction_dialogue: Array[String]
@export var closure_dialogue: Array[String]


@export var objective: Dictionary[IdRefs.QUEST_OBJECTIVES, int]


@export var rewards: Dictionary[IdRefs.QUEST_REWARDS, int]
@export var prerequisites: Array
