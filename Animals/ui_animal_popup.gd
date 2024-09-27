extends Control

var animal_scene

func _ready():
	%CloseButton.pressed.connect(on_close)
	%SellAnimal.pressed.connect(on_sell_animal)
	
	%AnimalName.text = animal_scene.animal_res.name
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	%HungerProgressBar.value = animal_scene.needs_hunger
	%RestProgressBar.value = animal_scene.needs_rest
	%FunProgressBar.value = animal_scene.needs_play

func on_close():
	queue_free()

func on_sell_animal():
	animal_scene.queue_free()
	queue_free()
