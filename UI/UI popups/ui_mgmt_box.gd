extends CanvasLayer

var review_count = {}

@export var review_element : PackedScene

func _ready():
	%CloseButton.pressed.connect(queue_free)
	generate_reviews_tab()
	DataManager.reviews_changed.connect(generate_reviews_tab)
	FinanceManager.current_month_changed.connect(generate_finances_tab)
	generate_finances_tab()

func generate_reviews_tab():
	review_count.clear()
	for child in %ReviewContainer.get_children():
		child.queue_free()
	for modifier in DataManager.modifier_list:
		if modifier in review_count.keys():
			review_count[modifier] += 1
		else:
			review_count[modifier] = 1

	for element in review_count.keys():
		var review_instance = review_element.instantiate()
		review_instance.description = ModifierManager.peep_modifiers[element].description
		review_instance.count = review_count[element]
		review_instance.visible = true
		%ReviewContainer.add_child(review_instance)

func generate_finances_tab():
	generate_finance_month_element(%CurrentMonth, FinanceManager.current_month_stats)
	if FinanceManager.monthly_stats.size() > 0:
		%LastMonthContainer.show()
		generate_finance_month_element(%LastMonth, FinanceManager.monthly_stats[FinanceManager.monthly_stats.size() - 1])
	else:
		%LastMonthContainer.hide()
	if FinanceManager.monthly_stats.size() > 1:
		%SecondLastMonthContainer.show()
		generate_finance_month_element(%SecondLastMonth, FinanceManager.monthly_stats[FinanceManager.monthly_stats.size() - 2])
	else:
		%SecondLastMonthContainer.hide()

func generate_finance_month_element(element, financial_data):
	if (!financial_data):
		return
	var total = 0
	for child in element.find_child('IncomeEntries').get_children():
		child.queue_free()
	for child in element.find_child('ExpenditureEntries').get_children():
		child.queue_free()
	for key in financial_data['income']:
		var entry = HBoxContainer.new()
		var type_label = Label.new()
		type_label.text = str(key)
		var value_label = Label.new()
		value_label.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
		value_label.text = str(financial_data['income'][key])
		entry.add_child(type_label)
		entry.add_child(value_label)
		element.find_child('IncomeEntries').add_child(entry)
		total += financial_data['income'][key]
	for key in financial_data['expenditures']:
		var entry = HBoxContainer.new()
		var type_label = Label.new()
		type_label.text = str(key)
		var value_label = Label.new()
		value_label.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
		value_label.text = str(financial_data['expenditures'][key])
		entry.add_child(type_label)
		entry.add_child(value_label)
		element.find_child('ExpenditureEntries').add_child(entry)
		total -= financial_data['expenditures'][key]
		
	element.find_child('TotalValue').text = str(total)
		
