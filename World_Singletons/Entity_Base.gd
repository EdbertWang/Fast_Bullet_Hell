extends Node

@onready var player = preload("res://Entities/Player/player.tscn")
@export var spawn_power : int = 0
@onready var enemies : Array[Object] = [] # Store the possible enemies to spawn in an array
@onready var enemy_names : Array[String] = [] # Store their possible names, use this mostly to index
@onready var seen_chunks = {} # Map Vector2 to boolean

func spawn_player(player_pos: Vector2):
	var p = player.instantiate()
	p.position = player_pos
	add_child(p)

func spawn_enemies(curr_chunk : Vector2): # Try to get random enemy spawns
	var level_size = SINGLETONS.tile_base.level_size
	#var camera_size = SINGLETONS.tile_base.camera_size
	if curr_chunk in seen_chunks: # respawn enemies
		for i in seen_chunks[curr_chunk]:
			var index = enemy_names.find(i["unit_name"])
			if index >= 0:
				# Only Spawn the first enemy in unit list
				var e = enemies[index].instantiate()
				e = e.spawn(i["unit_name"], Vector2.ZERO, [])
				e[0].set_properties(i)
				add_child(e[0])
	else:
		var curr_spawn_power = spawn_power
		var start_index : int = randi_range(0,enemy_names.size() - 1)
		var curr_index : int = start_index
		var fail_match : int = 0
		var loc : Array = SINGLETONS.tile_base.spawn_zones
		while curr_spawn_power > 0 and fail_match < 2:
			var curr_enemy : Array = DATABASE.get_enemy(enemy_names[curr_index])
			var curr_enemy_spawn_cost : int = int(curr_enemy[DATABASE.get_enemy_property_index("SpawnCost")])
			if curr_enemy_spawn_cost <= curr_spawn_power:
				# Spawn the chosen enemy a random number of times
				var times = int(curr_spawn_power / curr_enemy_spawn_cost)
				times -= randi_range(0,int(times / 3))
				times = max(times,1)
				curr_spawn_power -= curr_enemy_spawn_cost * times
				for i in range(times):
					#var spawn_loc : Vector2 = Vector2(randi_range(0,level_size.x), randi_range(0,level_size.y))
					var spawn_loc : Vector2 = loc[randi() % loc.size()]
					var e = enemies[curr_index].instantiate()
					for new_e in e.spawn(enemy_names[curr_index], spawn_loc, []): # TODO: passing args to certain enemies
						self.add_child(new_e)
				start_index = curr_index
				fail_match = 0
			curr_index += 1
			if curr_index == enemies.size():
				curr_index = 0
			if curr_index == start_index: # Does 2 passes to ensure that nothing left can be spawned
				fail_match += 1

func load_enemies(curr_chunk : Vector2, biome : String, distance : int): # Put enemies into the enemies list
	if curr_chunk in seen_chunks: return # Not necessary if already seen
	var biome_index = DATABASE.get_enemy_property_index("SpawnInfo")
	for i in DATABASE.ENEMIES: # i is the name of the enemy
		var enemy_val = DATABASE.ENEMIES[i]
		# Check if enemy can spawn in this biome, and if we are at right distance
		#print(enemy_val)
		if enemy_val[biome_index].has(biome) and distance >= enemy_val[biome_index][biome][0] and distance <= enemy_val[biome_index][biome][1]:
			enemies.append(load("res://Entities/"+ i + "/" + i + ".tscn"))
			enemy_names.append(i)

func save_enemies(curr_tile : Vector2): # Saves relevant data of enemies in a dictionary
	var curr_enemies = []
	for i in self.get_children():
		if not i.is_in_group("player"):
			curr_enemies.append(i.get_save_data()) # get_save_data returns a dictionary with the things we need to save
			i.queue_free()
	seen_chunks[curr_tile] = curr_enemies
	
