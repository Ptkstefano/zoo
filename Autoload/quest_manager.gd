extends Node


## Waiting quest is a quest that has been given a in-map quest giver but the player hasn't activated yet
var current_waiting_quest : quest_res
var active_quest : Quest

var quest_giver_exists : bool = false

var completed_quests : Array[IdRefs.QUEST_IDS]

@export var quest_resources : Array[quest_res]

var quest_list = {}
var tutorial_quest_list = {}

var pending_tutorial_quests : Array[IdRefs.QUEST_IDS]



func start() -> void:
	$QuestTimer.timeout.connect(on_quest_timer_timeout)
	$QuestTimer.start()
	setup_quest_list()
	SignalBus.quest_activated.connect(activate_quest)
	SignalBus.speech_ended.connect(activate_quest)
	return


func activate_quest():
	print('activate quest')
	if !current_waiting_quest:
		return
	QuestManager.quest_giver_exists = false
	SignalBus.quest_started.emit(current_waiting_quest)
	var new_quest = Quest.new()
	new_quest.quest_resource = current_waiting_quest
	active_quest = new_quest
	current_waiting_quest = null

func add_waiting_quest(quest_resource : quest_res):
	current_waiting_quest = quest_resource
	SignalBus.activate_quest_giver.emit(quest_resource.quest_giver)
	## TODO - activate quest giver

func on_quest_timer_timeout():
	if !GameManager.game_running:
		return
	if active_quest:
		return
	if current_waiting_quest:
		return
	find_new_quest()


func find_new_quest():
	if pending_tutorial_quests.size() > 0:
		add_waiting_quest(tutorial_quest_list[pending_tutorial_quests[0]])
		
		
func setup_quest_list():
	for quest in quest_resources:
		if quest.is_tutorial_quest:
			tutorial_quest_list[quest.id] = quest
			if quest.id not in completed_quests:
				pending_tutorial_quests.append(quest.id)
		else:
			quest_list[quest.id] = quest
