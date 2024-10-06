extends Node

var bolt = preload("res://Abilities/Firebolt/Firebolt_Inst.tscn")

func execute(s: Object):
	#print("Execute Called")
	var direction = s.get_local_mouse_position().angle()
	var layer = 3 # Set to collide with enemy layer
	var new_bolt = bolt.instantiate()
	new_bolt.config(s,s.position, direction, layer)
	add_child(new_bolt)
