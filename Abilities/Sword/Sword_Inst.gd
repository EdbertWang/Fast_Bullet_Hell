extends Area2D

var parent
var swing_time : float
var damage : int

func config(s=null,pos=Vector2(0,0), rot = 0, layer = 1,dmg = 5,swing_speed = 0.4, size = Vector2(1,1)):
	#print("Config Called")
	parent = s
	position = pos
	rotation = rot + deg_to_rad(180)
	scale = size
	swing_time = swing_speed
	damage = dmg 
	set_collision_layer_value(layer,true)
	#$CollisionShape2D.add_collision_exception(s) figure out how to properly stop collisions with player

	
func _ready():
	var tween = create_tween()
	tween.tween_property(self,"rotation",rotation + deg_to_rad(180),swing_time)
	tween.tween_callback(queue_free)
	#tween.tween_callback(func(): remove = true)
	tween.play()

func _physics_process(_delta):
	if parent != null and self != null: # In case parent dies while swinging - Not Fixed TODO, likely need to make this instance specific
		position = parent.position
