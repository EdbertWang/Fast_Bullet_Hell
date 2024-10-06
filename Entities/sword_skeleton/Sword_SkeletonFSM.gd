extends FSM


func _init() -> void:
	_add_state("idle")
	_add_state("chase")
	_add_state("hurt")
	_add_state("dead")
	
	
func _ready() -> void:
	set_state(states.idle)
	
	
func _state_logic(_delta: float) -> void:
	if state == states.chase:
		parent.shoot()
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
		states.chase:
			if parent.too_far_from_player():
				return states.idle
	return -1
	
	
func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			sprite.play("idle")
			parent.curr_ai = Callable(parent,"idle")
		states.chase:
			sprite.play("walk")
			parent.curr_ai = Callable(parent,"chase")
		states.hurt:
			animation_player.play("hurt")
		states.dead:
			animation_player.play("dead")
	
