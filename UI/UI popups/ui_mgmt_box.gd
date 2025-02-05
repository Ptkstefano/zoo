extends CanvasLayer

var review_count = {}

@export var review_element : PackedScene

@export var enclosure_element : PackedScene

@export var staff_element : PackedScene

@export var level_star : Texture
@export var level_star_half : Texture

@export var zookeeper_unique_icon : Texture
@export var zookeeper_icon : Texture

var star_instances

signal popup_closed

func _ready():
	%CloseButton.pressed.connect(on_popup_closed)
	generate_reviews_tab()
	ZooManager.reviews_changed.connect(generate_reviews_tab)
	FinanceManager.current_month_changed.connect(generate_finances_tab)
	generate_finances_tab()
	generate_staff_tab()
	star_instances = %UI_ReputationStars.get_children()
	ZooManager.zoo_reputation_updated.connect(on_reputation_update)
	on_reputation_update(ZooManager.reputation)
	
	%ZooOpenCheckbox.set_pressed_no_signal(ZooManager.zoo_entrance_open)
	%ZooOpenCheckbox.toggled.connect(ZooManager.set_zoo_entrance_open)
	%Minus.pressed.connect(entrance_price_change.bind(-1))
	%Plus.pressed.connect(entrance_price_change.bind(1))
	%Price.text = Helpers.money_text(ZooManager.entrance_price)
	
	%HireZookeeperButton.pressed.connect(on_hire_zookeeper)
	
	for enclosure_entry in ZooManager.zoo_enclosures.keys():
		if !ZooManager.zoo_enclosures[enclosure_entry]['species']:
			continue
		var element = enclosure_element.instantiate()
		element.enclosure_scene = ZooManager.zoo_enclosures[enclosure_entry]['node']
		%EnclosureListContainer.add_child(element)
	

func on_popup_closed():
	popup_closed.emit()

func generate_reviews_tab():
	review_count.clear()
	for child in %ReviewContainer.get_children():
		child.queue_free()

	for review in ZooManager.review_list:
		var review_instance = review_element.instantiate()
		review_instance.review = review
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
		
func on_reputation_update(reputation):
	var rounded = round(reputation * 2) * 0.5
	
	var full_stars = int(floor(rounded))
	var has_half_star = (rounded - full_stars) > 0

	for i in range(5):
		star_instances[i].custom_minimum_size = Vector2(76, 72)
		if i + 1 <= full_stars:
			star_instances[i].texture = level_star
		else:
			if i == full_stars and has_half_star:
				star_instances[i].texture = level_star_half
			else:
				star_instances[i].texture = null
				star_instances[i].custom_minimum_size = Vector2.ZERO

func entrance_price_change(amount):
	ZooManager.update_entrance_price(ZooManager.entrance_price + amount)
	%Price.text = Helpers.money_text(ZooManager.entrance_price)
	return

func generate_staff_tab():
	for staff in ZooManager.staff_list[IdRefs.STAFF_TYPES.ZOOKEEPER_UNIQUE]:
		var staff_entry = staff_element.instantiate()
		staff_entry.staff_scene = staff['scene']
		staff_entry.set_icon(zookeeper_unique_icon)
		%ZookeeperContainer.add_child(staff_entry)
	for staff in ZooManager.staff_list[IdRefs.STAFF_TYPES.ZOOKEEPER]:
		var staff_entry = staff_element.instantiate()
		staff_entry.staff_scene = staff['scene']
		staff_entry.set_icon(zookeeper_icon)
		%ZookeeperContainer.add_child(staff_entry)
		
func on_hire_zookeeper():
	SignalBus.hire_staff.emit(IdRefs.STAFF_TYPES.ZOOKEEPER)
