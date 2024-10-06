extends Enemy

@export var casting = false # needs to be exported to be accessible in animation player
@export var flee_range : int = 100
@export var flee_max_dist : int = 200
@export var cast_range : int = 300

var bolt = preload("res://Entities/caster_skeleton/caster_projectile.tscn")
var last_target : Vector2

@onready var bolt_cast_timer : Timer = $Bolt_Cast_Timer
var charged : bool = false
var can_shoot_bolt : bool = true

func in_range():
	if player != null and global_position.distance_to(player.position) < cast_range:
		return true
	return false

func too_close():
	if player != null and position.distance_to(player.position) < flee_range:
			return true
	return false
	
func fully_fled():
	if player != null and position.distance_to(player.position) < flee_max_dist:
			return true
	return false

func track_player():
	if in_range():
		last_target = player.position

func cast_bolt():
	var new_bolt = bolt.instantiate()

	new_bolt.position = global_position
	new_bolt.direction = (last_target - global_position).normalized()
	new_bolt.rotation = (last_target - global_position).angle()
	
	new_bolt.speed = 200
	
	SINGLETONS.proj_base.add_child(new_bolt)
	
	can_shoot_bolt = false
	bolt_cast_timer.start()



func flee():
	if player != null:
		nav.target_position = global_position + (global_position - player.position).normalized() * 100


func _on_bolt_cast_timer_timeout():
	can_shoot_bolt = true
