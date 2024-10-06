extends FSM


func _init() -> void:
	_add_state("idle")
	_add_state("chase")
	_add_state("flee")
	_add_state("casting")
	_add_state("hurt")
	_add_state("dead")
	
	
func _ready() -> void:
	set_state(states.idle)
	
	
func _state_logic(_delta: float) -> void:
	if state == states.chase:
		parent.chase()
	elif state == states.flee:
		parent.flee()
	elif state == states.casting:
		parent.track_player()
		
	parent.do_nav()
	parent.movement()

func _get_transition() -> int:
	match state:
		states.idle:
			if parent.is_close_to_player():
				return states.chase
		states.hurt:
			#if not animation_player.is_playing():
			return previous_state
		states.flee:
			if not parent.fully_fled():
				return states.idle
		states.chase:
			if parent.too_close():
				return states.flee
			elif parent.can_shoot_bolt and parent.in_range():
				return states.casting
			elif parent.too_far_from_player():
				return states.idle
		states.casting:
			if not animation_player.is_playing():
				return previous_state
	return -1
	
	
func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			sprite.play("idle")
			parent.curr_ai = Callable(parent,"idle")
		states.chase:
			parent.curr_ai = Callable(parent,"chase")
			sprite.play("walk")
		states.flee:
			parent.curr_ai = Callable(parent,"flee")
		states.hurt:
			animation_player.play("hurt")
		states.dead:
			animation_player.play("dead")
		states.casting: # Stop moving and start the cast animation
			parent.move_vec = Vector2.ZERO
			parent.curr_ai = Callable(parent,"idle")
			animation_player.play("casting_spell")

	
func _exit_state(state_exited: int) -> void:
	match state_exited:
		states.casting:
			parent.cast_bolt() # Release the bolt once the animation finishes
