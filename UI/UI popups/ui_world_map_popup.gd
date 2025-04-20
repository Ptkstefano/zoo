extends CanvasLayer

signal popup_closed

var chosen_expedition_resource : expedition_resource

func _ready() -> void:
	%CloseButton.pressed.connect(on_popup_closed)
	%WorldMap.expedition_chosen.connect(on_expedition_chosen)
	%StartExpeditionButton.pressed.connect(on_start_expedition)
	%WorldMapScroll.scrolling.connect(on_world_map_scroll)
	#%WorldMapScroll.max_value = %WorldMapScrollContainer.size.x
	
func on_popup_closed():
	popup_closed.emit()

func on_expedition_chosen(expedition : expedition_resource):
	%ExpeditionInfoContainer.show()
	
	for child in %PossibleAnimals.get_children():
		child.queue_free()
	
	chosen_expedition_resource = expedition
	%ExpeditionName.text = expedition.tr_name
	%"Expedition description".text = expedition.tr_description
	for animal in  expedition.possible_animals:
		var texture_rect = TextureRect.new()
		texture_rect.custom_minimum_size = Vector2(80,80)
		texture_rect.texture = ContentManager.animals[animal].icon
		%PossibleAnimals.add_child(texture_rect)
		
func on_world_map_scroll():
	%WorldMapScrollContainer.scroll_horizontal = %WorldMapScroll.value

func on_start_expedition():
	ExpeditionManager.start_expedition(chosen_expedition_resource)
