extends Node2D

class_name AnimalManager

var available_animals : Array[animal_resource]

@export var enclosure_manager : EnclosureManager
@export var animal_scene : PackedScene

@export var ui_animal_element : PackedScene
var animal_count = 0

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#ResearchManager.unlocked_animals_changed.connect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_stored_animal(coordinate, stored_animal : StoredAnimal):
	var saved_data = stored_animal.get_saved_data()
	spawn_animal(coordinate, stored_animal.animal_res, saved_data, false, stored_animal.animal_gender)

func spawn_animal(coordinate, animal_res : animal_resource, saved_data, is_spawned_infant : bool, selected_spawn_gender):
	if !check_if_valid_position(coordinate, animal_res):
		return
		
	var cell = TileMapRef.local_to_map(coordinate)
	var found_enclosure = enclosure_manager.get_enclosure_by_cell(cell)
		
	var spawned_animal = animal_scene.instantiate()
	
	if saved_data:
		spawned_animal.id = saved_data.id
	else:
		## This means animal was bought
		if !is_spawned_infant:
			if !FinanceManager.is_amount_available(animal_res.cost):
				SignalBus.tooltip.emit(tr('TOOLTIP_NOT_ENOUGH_MONEY'), null)
				return
			FinanceManager.remove(animal_res.cost, IdRefs.PAYMENT_REMOVE_TYPES.CONSTRUCTION)
			SignalBus.money_tooltip.emit(animal_res.cost, false, coordinate)
			spawned_animal.id = ZooManager.generate_animal_id()
	
	spawned_animal.initialize_animal(animal_res, coordinate, found_enclosure, saved_data, is_spawned_infant, selected_spawn_gender)
	spawned_animal.animal_removed.connect(despawn_animal)
	spawned_animal.spawn_cub.connect(spawn_cub)
	
	add_child(spawned_animal)
	
	SignalBus.animal_placed.emit(spawned_animal.id)
	
	Effects.wobble(spawned_animal)
	found_enclosure.add_animal(spawned_animal)
	animal_count += 1

func spawn_cub(parent : Animal):
	spawn_animal(parent.global_position + Vector2(0, 10), parent.animal_res, null, true, null)
	return

func despawn_animal(animal):
	animal_count -= 1
	animal.queue_free()

func check_if_valid_position(coordinate, animal_res) -> bool:
	var cell = TileMapRef.local_to_map(coordinate)
	var found_enclosure = enclosure_manager.get_enclosure_by_cell(cell)
	
	if !found_enclosure:
		SignalBus.tooltip.emit(tr('TOOLTIP_REQUIRES_ENCLOSURE'), null)
		return false
	if !found_enclosure.entrance_door_cell:
		SignalBus.tooltip.emit(tr('TOOLTIP_REQUIRES_ENTRANCE'), null)
		return false
		
	if found_enclosure.enclosure_species != null:
		if found_enclosure.enclosure_species != animal_res:
			SignalBus.tooltip.emit(tr('TOOLTIP_NO_ANIMAL_MIXING'), null)
			return false
			
	if found_enclosure.fence_res.fence_level < animal_res.minimum_fence_level:
		SignalBus.tooltip.emit(tr('TOOLTIP_ENCLOSURE_NOT_SAFE'), null)
		return false
		
	return true
