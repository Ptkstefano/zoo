extends Control

signal popup_closed

var calculated_value

func _ready() -> void:
	## Perhaps move this to a more suitable script
	var clamped_seconds = clampf(TimeManager.get_delta_unix_time(), 0, 86400)
	var proportion = (clamped_seconds / 86400.0)
	calculated_value = int(ZooManager.zoo_rating * proportion * 6)
	
	%GrantValue.text = Helpers.money_text(calculated_value)
	%CollectButton.pressed.connect(on_collect)
	
func on_collect():
	FinanceManager.add(calculated_value, IdRefs.PAYMENT_ADD_TYPES.GRANT)
	popup_closed.emit()
