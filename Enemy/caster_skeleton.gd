extends "res://Utilities/Base_Enemy.gd"


func chaser_ai():
	super()
	if current_target != null:
		if position.distance_to(current_target.position) < 100:
			# Retreat AI
			pass
		elif position.distance_to(current_target.position) < 500:
			# Casting Animation
			use_ability(0) # Should use firebolt
	else:
		pass

