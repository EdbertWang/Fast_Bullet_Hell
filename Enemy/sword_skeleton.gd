extends "res://Utilities/Base_Enemy.gd"


func chaser_ai():
	super()
	if current_target != null and position.distance_to(current_target.position) < 100:
		use_ability(0) # Should use sword

