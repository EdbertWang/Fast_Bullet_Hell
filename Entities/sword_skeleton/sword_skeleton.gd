extends Enemy

const slice_tscn = preload("res://Entities/Sword_Skeleton/sword_skeleton_slash.tscn")
@onready var sword_timer : Timer = get_node("Sword_Attack_Timer")
var charged : bool = false
var can_shoot_sword : bool = true

func shoot():
	if can_shoot_sword:
		var slice_inst = slice_tscn.instantiate()
		slice_inst.position = global_position
		slice_inst.direction = (nav.target_position - global_position).normalized()
		slice_inst.rotation = (nav.target_position - global_position).angle()
		
		slice_inst.speed = 100
		
		SINGLETONS.proj_base.add_child(slice_inst)
		
		can_shoot_sword = false
		sword_timer.start()
		



func _on_sword_attack_timer_timeout():
	can_shoot_sword = true
