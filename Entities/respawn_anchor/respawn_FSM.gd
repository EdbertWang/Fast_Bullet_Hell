extends FSM

func _init() -> void:
	_add_state("idle")
	_add_state("dead")
	
func _ready() -> void:
	set_physics_process(false) # respawn anchor only cares when its directly signaled
	set_state(states.idle)
	
func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			sprite.play("idle")
		states.dead:
			parent.emit_respawn_anchor_break()
			animation_player.play("dead")
