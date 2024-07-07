extends Area2D

@export_enum("Cooldown", "HitOnce", "DisableHithbox","Enable") var hurtboxtype = 0

@onready var coll = $CollisionShape2D
@onready var disableTimer = $Timer

signal hurt(damage,angle,knockback)

var hit_once_arr = []

func _on_area_entered(area):
	print("Hurtbox Entered")
	if area.is_in_group("projectile"):
		if not area.get("damage") == null:
			match hurtboxtype:
				0: # Cooldown
					coll.call_deferred("set","disabled",true)
					disableTimer.start()
				1: # Hitonce
					if hit_once_arr.has(area) == false:
						hit_once_arr.append(area)
						if area.has_signal("remove_from_array"):
							if not area.is_connected("remove_from_array",Callable(self,"remove_from_list")):
								area.connect("remove_from_array", Callable(self,"remove_from_list"))
					else:
						return
				2: # Disable Hitbox 
					if area.has_method("disable"):
						area.disable()
				3: # Enable
					pass
			var damage = area.damage
			var angle = Vector2.ZERO
			var knock_back = 0
			if not area.get("angle") == null:
				angle = area.angle
			if not area.get("knock_back") == null:
				knock_back = area.knock_back
				
			print("Sending Hurt Signal")
			emit_signal("hurt",damage,angle,knock_back)
			if area.has_method("enemy_hit"):
				area.enemy_hit(1)

func remove_from_list(obj):
	if hit_once_arr.has(obj):
		hit_once_arr.erase(obj)

func _on_timer_timeout():
	coll.call_deferred("set","disabled",false)


func _on_body_entered(body):
	print("temp")
