extends ProgressBar

func _ready() -> void:
	ResearchManager.research_progress_updated.connect(update_value)
	
func update_value():
	value = ResearchManager.current_research_progress
