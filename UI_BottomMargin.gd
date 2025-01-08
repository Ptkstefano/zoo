extends MarginContainer

func _ready():
	SignalBus.money_changed.connect(on_money_changed)
	%ScoreButton.pressed.connect(on_score_button)

func on_money_changed(amount):
	%MoneyLabel.text = "$" + str("%.2f" % amount)

func on_score_button():
	SignalBus.open_box.emit(IdRefs.UI_BOXES.MANAGEMENT)
