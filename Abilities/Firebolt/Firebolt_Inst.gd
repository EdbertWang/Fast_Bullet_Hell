extends Area2D

var parent
var life_time : float = 1.5
var damage : int
var speed : float

func config(s=null,pos=Vector2(0,0), rot = 0, layer = 1,spd = 5, dmg = 5, size = Vector2(1,1)):
	#print("Config Called")
	parent = s
	position = pos
	rotation = rot + deg_to_rad(270)
	scale = size
	damage = dmg 
	speed = spd
	set_collision_layer_value(layer,true)
	#$CollisionShape2D.add_collision_exception(s) figure out how to properly stop collisions with player

	
func _ready():
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = life_time
	timer.one_shot = true
	timer.start()
	timer.connect("timeout", _on_timer_timeout)
	$AnimationPlayer.play("Firebolt")

func _on_timer_timeout() -> void:
	queue_free()

func _physics_process(_delta):
	position += Vector2.from_angle(rotation - deg_to_rad(270)) * speed

