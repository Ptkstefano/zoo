extends Node2D

class_name AnimalManager

var available_animals : Array[animal_resource]

@export var enclosure_manager : EnclosureManager
@export var animal_scene : PackedScene

@onready var animal_menu = %AnimalSelectionContainer
@export var ui_animal_element : PackedScene
var animal_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## TODO - Generate list according to unlocks
	for key in ContentManager.animals.keys():
		available_animals.append(ContentManager.animals[key])
	update_animal_menu()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_animal_menu():
	for child in animal_menu.get_children():
		child.queue_free()
		
	for animal_res in available_animals:
		var element = ui_animal_element.instantiate()
		element.animal_res = animal_res
		animal_menu.add_child(element)
		
	$"../../UI".update_ui()


func spawn_animal(coordinate, animal_res : animal_resource, saved_data, is_spawned_infant : bool, selected_spawn_gender):
	## Find what enclosure the player wants to add an animal to
	var cell = TileMapRef.local_to_map(coordinate)
	var found_enclosure = enclosure_manager.get_enclosure_by_cell(cell)
	if !found_enclosure:
		SignalBus.tooltip.emit('Animal requires enclosure')
		return
	if !found_enclosure.entrance_door_cell:
		SignalBus.tooltip.emit('Enclosure requires entrance')
		return
		
	if found_enclosure.enclosure_species != null:
		if found_enclosure.enclosure_species != animal_res:
			return
		
	var spawned_animal = animal_scene.instantiate()

	
	if saved_data:
		spawned_animal.id = saved_data.id
	else:
		if !is_spawned_infant:
			if !FinanceManager.is_amount_available(animal_res.cost):
				SignalBus.tooltip.emit('Not enough money')
				return
			FinanceManager.remove(animal_res.cost, IdRefs.PAYMENT_REMOVE_TYPES.CONSTRUCTION)
			SignalBus.money_tooltip.emit(animal_res.cost, false, coordinate)
			spawned_animal.id = ZooManager.generate_animal_id()
	
	spawned_animal.initialize_animal(animal_res, coordinate, found_enclosure, saved_data, is_spawned_infant, selected_spawn_gender)
	spawned_animal.animal_removed.connect(despawn_animal)
	spawned_animal.spawn_cub.connect(spawn_cub)
	
	add_child(spawned_animal)
	Effects.wobble(spawned_animal)
	found_enclosure.add_animal(spawned_animal)
	animal_count += 1

func spawn_cub(parent : Animal):
	spawn_animal(parent.global_position + Vector2(0, 10), parent.animal_res, null, true, null)
	return

func despawn_animal(animal):
	animal_count -= 1
