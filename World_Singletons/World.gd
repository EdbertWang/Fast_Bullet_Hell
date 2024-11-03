extends Node2D


#@onready var phys_obj_base = $Physical_Obj_Base
@onready var entity_base = $Entity_Base
@onready var proj_base = $Projectile_Base
@onready var tile_base = $Tile_Base
@onready var in_proj_base  = {} # Dictonary of attack nodes and how many users



var player : Object

func _ready(): # Need to use postload since ready of children called before ready of parent
	print("Enabling Singletons")
	SINGLETONS.post_load()
	
	print("Loading Data")
	DATABASE.parse_enemies()
	DATABASE.parse_biome_colors()
	
	print("Generating Level")
	DATABASE.generate_biome_grid()
	tile_base.generate_chunk(Vector2(50,50))
	
	print("Spawning Entites")
	entity_base.spawn_player(Vector2(50,50))
	entity_base.load_enemies(Vector2(0,0), "Forest",0)
	entity_base.spawn_enemies(Vector2(0,0))
	
	player = entity_base.get_node("Player")
	#tile_base.unload_chunk(level_size,camera_size)


func move_chunk(move_vec : Vector2): # Load new chunk when player moves into it
	print("Changing tiles")
	
	var curr_chunk = tile_base.curr_chunk
	# for position, the cartesian cordinates for position can be though of in the same way as 
	# a standard x y plane, with the center of the tile grid as (0,0)
	entity_base.save_enemies(curr_chunk)
	curr_chunk += move_vec
	tile_base.curr_chunk = curr_chunk
	tile_base.unload_chunk()
	tile_base.generate_chunk(curr_chunk)
	
	#Remove all remoaning projectiles after leaving the chunk
	for proj in proj_base.get_children():
		for i in proj.get_children():
			i.queue_free()
	
	entity_base.load_enemies(curr_chunk,"Forest",max(abs(curr_chunk.x), abs(curr_chunk.y))) # TODO: change forest to get biome from data container
	entity_base.spawn_enemies(curr_chunk)

