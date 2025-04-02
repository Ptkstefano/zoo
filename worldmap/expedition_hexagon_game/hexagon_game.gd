extends Node2D

var maximum_tries : int = 25
var tries_attempted : int = 0
var animal_count = 2

var game_active : bool = true

enum ICONS {
	ANIMAL,
	FOOTSTEPS,
	DISTURBED_VEGETATION,
	DROPPING,
}

var revealed_tiles : Array[Vector2i] = []

var found_animals : Array = []

## blocked_tiles are tiles occupied by blockers and they can't be played
var blocked_tiles : Array[Vector2i]
## used_tiles are tiles occupied by animals or clues and they can be played
var used_tiles = {}


var placed_animals = []
var captured_animals = []

@export var animal_icon : Texture2D
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
						
						if found_animals.size() >= animal_count:
							end_hexagon_game()
							
						if tries_attempted >= maximum_tries:
							end_hexagon_game()
		
	if event is InputEventMouseMotion:
		$TileLabel.text = str(%SafariTilemap.local_to_map(event.position))

func spawn_icon(tile, clue_type):
	var animal_icon_sprite = Sprite2D.new()

	if clue_type == ICONS.FOOTSTEPS:
		animal_icon_sprite.texture = footstep_icon
	if clue_type == ICONS.DISTURBED_VEGETATION:
		animal_icon_sprite.texture = disturbed_vegetation_icon
	if clue_type == ICONS.DROPPING:
		animal_icon_sprite.texture = dropping_icon
	if clue_type == ICONS.ANIMAL:
		animal_icon_sprite.texture = animal_icon
			

	animal_icon_sprite.scale = Vector2(3,3)
	animal_icon_sprite.global_position = %SafariTilemap.map_to_local(tile) + %SafariTilemap.position
	animal_icon_sprite.hide()
	%Icons.add_child(animal_icon_sprite)
	
	return animal_icon_sprite

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

	
	for animal in animal_count:
		
		var placed_animal = {}
		
		var random_tile = Vector2i(randi_range(3,10), randi_range(3,10))
		while random_tile in blocked_tiles:
			random_tile = Vector2i(randi_range(3,10), randi_range(3,10))
		
		placed_animal.animal_tile = random_tile
		used_tiles[random_tile] = spawn_icon(placed_animal.animal_tile, ICONS.ANIMAL)
		
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
								used_tiles[tile] = spawn_icon(tile, ICONS.FOOTSTEPS)
					
		
		## Generate vegetation clue tiles
		placed_animal.vegetation_clue_tiles = []
		for i in 10:
			var tile = placed_animal.animal_tile + Vector2i(randi_range(-3,2), randi_range(-3,2))
			if tile in valid_tiles:
				if tile not in blocked_tiles:
					if tile not in used_tiles:
						if tile != placed_animal.animal_tile:
							placed_animal.vegetation_clue_tiles.append(tile)
							used_tiles[tile] = spawn_icon(tile, ICONS.DISTURBED_VEGETATION)
						
		## Generate dropping clue tiles
		placed_animal.dropping_clue_tiles = []
		for i in 2:
			var tile = placed_animal.animal_tile + [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)].pick_random()
			if tile in valid_tiles:
				if tile not in blocked_tiles:
					if tile not in used_tiles:
						if tile != placed_animal.animal_tile:
							placed_animal.dropping_clue_tiles.append(tile)
							used_tiles[tile] = spawn_icon(tile, ICONS.DROPPING)
			else:
				tile = placed_animal.animal_tile + [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)].pick_random()
				if tile in valid_tiles:
					if tile not in blocked_tiles:
						if tile not in used_tiles:
							if tile != placed_animal.animal_tile:
								used_tiles.append(tile)
								placed_animal.dropping_clue_tiles.append(tile)
								used_tiles[tile] = spawn_icon(tile, ICONS.DROPPING)

func reveal_tile(tile):
	var atlas_coords = %SafariTilemap.get_cell_atlas_coords(tile)
	%SafariTilemap.set_cell(tile, 0, Vector2(atlas_coords.x,atlas_coords.y+1), 0)
	if tile in used_tiles.keys():
		used_tiles[tile].show()
		
	for animal in placed_animals:
		if tile == placed_animals.animal_tile:
			captured_animals.append(animal)
			
	if captured_animals.size() == animal_count:
		end_hexagon_game()


func on_debug():
	for child in %Icons.get_children():
		child.show()

func end_hexagon_game():
	await get_tree().create_timer(3).timeout
	print('Ending hexagon game')
	game_active = false
	hexagon_ended.emit()
