extends Node

# Reference for how to import CSV into godot
# https://github.com/godotengine/godot/issues/19627

# This class is a static container that will hold all the global data necessary 

enum tile_layers {
	BACKGROUND,
	PHYSICAL,
	DESTRUCTIBLE,
	FOREGROUND,
}

@onready var ENEMIES = {}
var ENEMY_PROPERTIES : Array
@onready var ABILITES = {}
@onready var BIOME_COLORS = {} # Biome colors is dictionary of biome name -> array of format (R,G,B,A)
@onready var BIOME_GRID = []

@export var mapSize : Vector2 = Vector2(5,5)

func generate_biome_grid():
	var curr_biomes = []
	var size = BIOME_COLORS.size()
	for i in range(4):
		var retry = true
		while retry:
			var biome_name = BIOME_COLORS.keys()[randi() % size]
			if biome_name not in curr_biomes:
				curr_biomes.append(biome_name)
				retry = false
	
	for i in range(2 * DataContainer.mapSize.x + 1):
		BIOME_GRID.append([])
		for j in range(2 * DataContainer.mapSize.y + 1): # Do a 4 way split
			if (i == DataContainer.mapSize.x and j == 2 * DataContainer.mapSize.y):
				BIOME_GRID[i].append([255,255,255,255]) #TODO: Find better color for home
			elif (i >= j and i >= (2 * DataContainer.mapSize.y + 1) - j):
				BIOME_GRID[i].append(BIOME_COLORS[curr_biomes[0]])
			elif (i < j and i >= (2 * DataContainer.mapSize.y + 1) - j):
				BIOME_GRID[i].append(BIOME_COLORS[curr_biomes[1]])
			elif (i >= j and i < (2 * DataContainer.mapSize.y + 1) - j):
				BIOME_GRID[i].append(BIOME_COLORS[curr_biomes[2]])
			elif (i < j and i < (2 * DataContainer.mapSize.y + 1) - j):
				BIOME_GRID[i].append(BIOME_COLORS[curr_biomes[3]])

func parse_biome_colors():
	var csv = []
	var file = FileAccess.open("res://Data/biome_tile_colors.csv", FileAccess.READ)
	while !file.eof_reached():
		var csv_rows = file.get_csv_line(",")
		csv.append(csv_rows)
	file.close()
	
	csv.pop_back() #remove last empty array get_csv_line() has created 
	csv.pop_front() #remove first array (headers) from the csv
	
	var items : Array = []
	var multi_item_dict : Dictionary = {}
	var multi_item_list : Array = []
	for i in csv: # Iterate over csv
		print(i)
		items.clear()
		var tile_name = i[0]
		i.remove_at(0)
		for j in range(i.size()):
			items.append(int(i[j]))
		BIOME_COLORS[tile_name] = items.duplicate(true)
	print(BIOME_COLORS)

func parse_enemies():
	# Read data from csv and save into array
	var csv = []
	var file = FileAccess.open("res://Data/enemies.csv", FileAccess.READ)
	while !file.eof_reached():
		var csv_rows = file.get_csv_line(",")
		csv.append(csv_rows)
	file.close()
	
	csv.pop_back() #remove last empty array get_csv_line() has created 
	ENEMY_PROPERTIES = Array(csv[0])
	print(ENEMY_PROPERTIES)
	csv.pop_front() #remove first array (headers) from the csv
	
	var items : Array = []
	var multi_item_dict : Dictionary = {}
	var multi_item_list : Array = []
	for i in csv: # Iterate over csv
		print(i)
		items.clear()
		var enemy_name = i[0]
		i.remove_at(0)
		for j in range(i.size()): # Iterate over csv line items
			multi_item_dict.clear()
			multi_item_list = i[j].split(",")
			if enemies_parse_multi(j, multi_item_list, multi_item_dict):
				items.append(multi_item_dict.duplicate(true))
			else:
				items.append(i[j])
		ENEMIES[enemy_name] = items.duplicate(true)
	print(ENEMIES)
	
func enemies_parse_multi(index : int, item_list : Array, item_dict : Dictionary) -> bool:
	var item_index : int = 0
	match ENEMY_PROPERTIES[index + 1]: # Increase index by 1 to account for removal of name
		"SpawnInfo":
			while item_index < item_list.size():
				item_dict[item_list[item_index]] = Vector2(int(item_list[item_index + 1]), int(item_list[item_index + 2]))
				item_index += 3
			return true
		"Abilites":
			while item_index < item_list.size():
				item_dict[item_list[item_index]] = true
				item_index += 1
			return true
	return false

func get_enemy(name : String) -> Array: # Returns array containing the properties of the enemy with the given name
	return ENEMIES[name]

func get_enemy_property_index(name : String) -> int: # Returns index of property, if not found returns -2
	return ENEMY_PROPERTIES.find(name) - 1 # Account for removal of name field

func parse_abilites():
	pass
