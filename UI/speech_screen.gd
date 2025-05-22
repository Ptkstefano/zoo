extends CanvasLayer

var speech_array : Array
var current_speech_index : int = 0

func _ready() -> void:
	%SpeechBubble.gui_input.connect(on_speech_bubble_input)
	SignalBus.quest_started.connect(on_quest_started)
	
func start_speech():
	SignalBus.speech_started.emit()
	next_speech()
	current_speech_index = 0
	GameManager.is_screen_busy = true
	show()
	
func on_quest_started(quest : quest_res):
	speech_array = quest.introduction_dialogue
	start_speech()
	
func next_speech():
	print('next speech')
	if !%SpeechTimer.is_stopped():
		return
	if current_speech_index >= speech_array.size():
		print('no more speech')
		end_speech()
	else:
		print('next speech printed')
		%SpeechText.text = tr(speech_array[current_speech_index])
		%SpeechTimer.start()
		current_speech_index += 1
	
	
func end_speech():
	print('ending speech')
	var tween = get_tree().create_tween()
	tween.tween_property(%SpeechBG, 'modulate', Color.TRANSPARENT, 2)
	tween.tween_property(%SpeechControl, 'modulate', Color.TRANSPARENT, 2)
	await get_tree().create_timer(2).timeout
	GameManager.is_screen_busy = false
	SignalBus.speech_ended.emit()
	hide()
	
	
func on_speech_bubble_input(event : InputEvent):
	if event.is_pressed():
		next_speech()
