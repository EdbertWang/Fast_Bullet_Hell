extends Node

var world
var tile_base
var proj_base
var entity_base

func post_load():
	world = get_tree().root.get_node("World")
	tile_base = world.get_node("Tile_Base")
	entity_base = world.get_node("Entity_Base")
	proj_base = world.get_node("Projectile_Base")
