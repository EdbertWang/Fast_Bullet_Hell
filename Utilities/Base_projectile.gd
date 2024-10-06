extends HitBox

class_name Base_Projectile

@export var speed : int = 50
var direction : Vector2


func _physics_process(delta):
	position += direction * speed * delta


func _on_lifetime_timeout():
	queue_free()
	
func entity_hit():
	queue_free()

func _on_body_entered(_body):
	queue_free()
