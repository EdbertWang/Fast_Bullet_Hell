extends FSM

func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("hurt")
	_add_state("dead")
	
	
func _ready() -> void:
	set_state(states.idle)
	
	
func _state_logic(_delta: float) -> void:
	if state == states.idle or state == states.move:
		parent.get_move_input()
		#parent.update_sprite()
		#parent.update_weapon_location()
		parent.shoot()
	parent.movement()
	
	
func _get_transition() -> int:
	match state:
		states.idle:
			if parent.move_vec != Vector2.ZERO:
				return states.move
		states.move:
			if parent.move_vec == Vector2.ZERO:
				return states.idle
		states.hurt:
			return states.idle
	return -1
	
	
func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			sprite.play("idle")
		states.move:
			sprite.play("move")
		states.hurt:
			animation_player.play("hurt")
		states.dead:
			if parent.can_respawn:
				parent.respawn_func()
			else:
				animation_player.play("dead")

