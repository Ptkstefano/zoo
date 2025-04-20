extends Node2D

var maximum_tries : int = 25
var tries_attempted : int = 0
var animal_count = 2

var game_active : bool = true

var hidden_animals = []

var revealed_tiles : Array[Vector2i] = []

## blocked_tiles are tiles occupied by blockers and they can't be played
var blocked_tiles : Array[Vector2i]
## used_tiles are tiles occupied by animals or clues and they can be played
var used_tiles = {}


var placed_animals = []
var captured_animals = []

@export var footstep_icon : Texture2D
@export var disturbed_vegetation_icon : Texture2D
@export var dropping_icon : Texture2D
@export var valid_tiles : Array[Vector2i] = []

signal hexagon_ended


var adjacent_hexagons: Array[Vector2i] = [
	Vector2i(1, 0),    # Right
	Vector2i(-1, 0),   # Left
	Vector2i(1, -1),   # Top-right
	Vector2i(-1, 1),   # Bottom-left
	Vector2i(0, 1),    # Bottom-right
	Vector2i(0, -1)    # Top-left
]

func _ready() -> void:
	$Debug.pressed.connect(on_debug)
	#$Start.pressed.connect(start_game)
	%QuitButton.pressed.connect(hexagon_ended.emit)
	
	## For debug purposes
	if hidden_animals.is_empty():
		hidden_animals= [ContentManager.animals[3], ContentManager.animals[3]]
	
	start_game()

func start_game():
	for icon in %Icons.get_children():
		icon.queue_free()
	tries_attempted = 0
	revealed_tiles.clear()
	blocked_tiles.clear()

	generate_tilemap()
	generate_animals()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if !game_active:
				return
			var tile_pos = (event.position / %SafariTilemap.scale) - %SafariTilemap.position
			var tile = %SafariTilemap.local_to_map(tile_pos)
			if tile in valid_tiles:
				if tries_attempted < maximum_tries:
					if tile not in revealed_tiles and tile not in blocked_tiles:
						tries_attempted += 1
						%TriesLabel.text = ('Tries left: ' + str(maximum_tries - tries_attempted))
						revealed_tiles.append(tile)
						reveal_tile(tile)
							
						if tries_attempted >= maximum_tries:
							end_hexagon_game()
		
	if event is InputEventMouseMotion:
		$TileLabel.text = str(%SafariTilemap.local_to_map(event.position))

func spawn_icon(tile, icon):
	var icon_sprite = Sprite2D.new()
	icon_sprite.texture = icon

	icon_sprite.scale = Vector2(3,3)
	icon_sprite.global_position = %SafariTilemap.map_to_local(tile) + %SafariTilemap.position
	icon_sprite.hide()
	%Icons.add_child(icon_sprite)
	
	return icon_sprite

func generate_tilemap():
	## Generate random playable tiles
	for x in 11:
		for y in 16:
			%SafariTilemap.set_cell(Vector2(x, y), 0, Vector2(randi_range(0,2), 0), 0)
			valid_tiles.append(Vector2i(x,y))

	## Generate blocker tiles
	for i in 8:
		var random_tile = Vector2i(randi_range(0,10), randi_range(0,15))
		%SafariTilemap.set_cell(random_tile, 0, Vector2(3, 0), 0)
		blocked_tiles.append(random_tile)
	




func generate_animals():
	
	for animal in hidden_animals:
		
		var placed_animal = {}
		
		var random_tile = Vector2i(randi_range(3,10), randi_range(3,10))
		while random_tile in blocked_tiles or random_tile in used_tiles:
			random_tile = Vector2i(randi_range(3,10), randi_range(3,10))
		
		placed_animal.animal_tile = random_tile
		placed_animal.animal_res = animal
		used_tiles[random_tile] = spawn_icon(placed_animal.animal_tile, animal.icon)
		
		## Generate footstep clue tiles
		var direction = adjacent_hexagons.pick_random()
		placed_animal.footstep_clue_tiles = []
		for i in range(1,4):
			var tile = placed_animal.animal_tile + (direction * i)
			if tile not in used_tiles:
				if tile in valid_tiles:
					if tile not in blocked_tiles:
							if tile != placed_animal.animal_tile:
								placed_animal.footstep_clue_tiles.append(tile)
								used_tiles[tile] = spawn_icon(tile, footstep_icon)
					
		
		## Generate vegetation clue tiles
		placed_animal.vegetation_clue_tiles = []
		for i in 10:
			var tile = placed_animal.animal_tile + Vector2i(randi_range(-3,2), randi_range(-3,2))
			if tile in valid_tiles:
				if tile not in blocked_tiles:
					if tile not in used_tiles:
						if tile != placed_animal.animal_tile:
							placed_animal.vegetation_clue_tiles.append(tile)
							used_tiles[tile] = spawn_icon(tile, disturbed_vegetation_icon)
						
		## Generate dropping clue tiles
		placed_animal.dropping_clue_tiles = []
		for i in 2:
			var tile = placed_animal.animal_tile + [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)].pick_random()
			if tile in valid_tiles:
				if tile not in blocked_tiles:
					if tile not in used_tiles:
						if tile != placed_animal.animal_tile:
							placed_animal.dropping_clue_tiles.append(tile)
							used_tiles[tile] = spawn_icon(tile, dropping_icon)
			else:
				tile = placed_animal.animal_tile + [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)].pick_random()
				if tile in valid_tiles:
					if tile not in blocked_tiles:
						if tile not in used_tiles:
							if tile != placed_animal.animal_tile:
								placed_animal.dropping_clue_tiles.append(tile)
								used_tiles[tile] = spawn_icon(tile, dropping_icon)
								
		placed_animals.append(placed_animal)

func reveal_tile(tile : Vector2i):
	var atlas_coords = %SafariTilemap.get_cell_atlas_coords(tile)
	%SafariTilemap.set_cell(tile, 0, Vector2(atlas_coords.x,atlas_coords.y+1), 0)
	if tile in used_tiles.keys():
		used_tiles[tile].show()
		
	for animal in placed_animals:
		if tile == animal.animal_tile:
			captured_animals.append(animal.animal_res)
			for clue_tile in animal.vegetation_clue_tiles:
				if is_instance_valid(used_tiles[clue_tile]):
					used_tiles[clue_tile].queue_free()
			for clue_tile in animal.footstep_clue_tiles:
				if is_instance_valid(used_tiles[clue_tile]):
					used_tiles[clue_tile].queue_free()
			for clue_tile in animal.dropping_clue_tiles:
				if is_instance_valid(used_tiles[clue_tile]):
					used_tiles[clue_tile].queue_free()
			
	if captured_animals.size() == animal_count:
		end_hexagon_game()


func on_debug():
	for child in %Icons.get_children():
		child.show()

func end_hexagon_game():
	if game_active:
		await get_tree().create_timer(3).timeout
		game_active = false
		hexagon_ended.emit()
