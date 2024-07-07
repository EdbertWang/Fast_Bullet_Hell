extends Node2D


@onready var phys_obj_base = $Physical_Obj_Base
@onready var entity_base = $Entity_Base
@onready var proj_base = $Projectile_Base
@onready var tile_base = $Tile_Base
@onready var in_proj_base  = {} # Dictonary of attack nodes and how many users

@onready var curr_chunk : Vector2 = Vector2(0,0)

@export var level_size : Vector2 = Vector2(100,100)
@export var camera_size : Vector2 = Vector2(100,100)

var player : Object

func _ready(): # Need to use postload since ready of children called before ready of parent
	print("Loading Data")
	DataContainer.parse_enemies()
	DataContainer.parse_biome_colors()
	
	print("Generating Level")
	DataContainer.generate_biome_grid()
	tile_base.generate_chunk(Vector2(0,0), level_size,camera_size)
	
	print("Spawning Entites")
	entity_base.spawn_player(Vector2(0,0))
	entity_base.load_enemies(Vector2(0,0), "Forest",0)
	entity_base.spawn_enemies(Vector2(0,0), level_size,camera_size)
	entity_base.call_post_load()
	
	'''
	print("Calling Post Load on Entities") #TODO: move to entity base
	for e in entity_base.get_children():
		e.connect("remove_from_world",_on_remove_from_world)
		e.post_load()
	'''
	player = entity_base.get_child(0) # player will always be first child since spawned first
	#tile_base.unload_chunk(level_size,camera_size)

func load_ability(name : String): # Add possible abilites to in_proj_base and proj_base
	if name not in in_proj_base:
		print("Loading new projectile ", name)
		var scene = load("res://Abilities/" + name + "/" + name + ".tscn")
		var scenenode = scene.instantiate()
		in_proj_base[name] = 1
		proj_base.add_child(scenenode)
		return scenenode
	else:
		print("Projectile Already in Base ", name)
		in_proj_base[name] += 1
		return proj_base.find_child(name,false,false)

func _on_remove_from_world(object: Object):
	print("Removing ", object)
	for i in object.abilities: # Track number of things using the ablity singltons
		in_proj_base[i.name] -= 1

	
func _physics_process(delta):
	pass

func create_new_chunk(move_vec : Vector2): # Load new chunk when player moves into it
	print("Changing tiles")
	
	# for position, the cartesian cordinates for position can be though of in the same way as 
	# a standard x y plane, with the center of the tile grid as (0,0)
	entity_base.save_enemies(curr_chunk)
	curr_chunk += move_vec
	tile_base.generate_chunk(curr_chunk,level_size,camera_size)
	
	#Remove all remoaning projectiles after leaving the chunk
	for proj in proj_base.get_children():
		for i in proj.get_children():
			i.queue_free()
	
	entity_base.load_enemies(curr_chunk,"Forest",max(abs(curr_chunk.x), abs(curr_chunk.y))) # TODO: change forest to get biome from data container
	entity_base.spawn_enemies(curr_chunk,level_size,camera_size)
	entity_base.call_post_load()
	

