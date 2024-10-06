extends CharacterBody2D
class_name Base_Unit

@onready var sprite = $AnimatedSprite2D
@onready var coll = $CollisionShape2D
@onready var animation = $AnimationPlayer
@onready var state_machine = $FSM

var unit_name : String

# Stats - gets set based on data in CSV files
@export var max_hp : int
@onready var curr_hp : int = max_hp
@export var max_mana : int
@export var mana_regen : int
@onready var curr_mana : int = max_mana
@export var armor : int

# Movement Related
@export var base_speed : int
@onready var move_speed : float = base_speed
@export var knock_back_recovery : float
@onready var move_vec : Vector2 = Vector2.ZERO
@onready var knock_back_applied : Vector2 = Vector2.ZERO

	
func _physics_process(_delta):
	move_and_slide()
	
func movement():
	velocity = move_vec.normalized() * move_speed + knock_back_applied
	
	# Slow object gradually after it gets hit
	if knock_back_applied != Vector2.ZERO: 
		knock_back_applied = lerp(knock_back_applied,Vector2.ZERO,knock_back_recovery)

func _on_hurt_box_hurt(damage: int, angle: Vector2, knockback : float):
	curr_hp -= damage

	if curr_hp > 0:
		state_machine.set_state(state_machine.states.hurt)
		knock_back_applied += angle * knockback
	else:
		state_machine.set_state(state_machine.states.dead)
		knock_back_applied += angle * knockback * 2
			

func get_save_data():
	return {"unit_name": self.unit_name,"position" : self.position, "curr_hp" : self.curr_hp, "curr_mana" : self.curr_mana}

func set_properties(args_dict):
	unit_name = args_dict["unit_name"]
	position = args_dict["position"]
	curr_hp = args_dict["curr_hp"]
	curr_mana = args_dict["curr_mana"]
	
	
