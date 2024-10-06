extends Enemy

var spawn_count = 0
var spawn_limit = 5
var spawn_options = ["sword_skeleton","caster_skeleton"]


func spawn_minions():
	for i in range(spawn_count,spawn_limit):
		var spawn_loc = Vector2(randf_range(-100,100),randf_range(-100,100))
		var tempe = SINGLETONS.entity_base.enemies[spawn_options.find(spawn_options[randi_range(0,spawn_options.size())])].instantiate()
		var new_e = tempe.spawn(tempe.name, spawn_loc, [])
		SINGLETONS.entity_base.add_child(new_e)
