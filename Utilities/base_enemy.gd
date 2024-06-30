extends "res://Utilities/Base_Unit.gd"

@onready var search_space = $SearchSpace # dict in_range shows what is in detection range
var move_target : Vector2 = position
var current_target = null

@onready var switch_ai = $Switch_AI
var fix_curr_ai : bool = false

@onready var orignal_position : Vector2

@export var spawn_cost : int



func _ready():
	orignal_position = position
	#super()

func set_target():
	var min_dist: float = 9999.0
	var min_obj = null
	for i in search_space.in_range.keys():
		if i.is_in_group("friendly"):
			var dist : float = self.position.distance_to(i.position)
			if dist < min_dist:
				min_dist = dist
				min_obj = i
	
	if min_obj != null:
		move_target = min_obj.position
	current_target = min_obj

func chaser_ai():
	#print(self, " is chasing")
	set_target()

func patrol_ai():
	#print(self, " is patroling")
	move_target = orignal_position + Vector2(randi_range(-200,200), randi_range(-200,200))
	
func retreat_ai(): # Current Target must be set to retreat
	print(self, " is retreating")
	move_target = 2 * position - current_target.position

func ai_control(): # TODO: How to properly do intelligent AI
	#print(current_target)
	current_target = null
	if search_space.in_range.size() > 0:
		chaser_ai()
	if current_target == null and not fix_curr_ai:
		patrol_ai()
		switch_ai.start(switch_ai.wait_time + randi_range(-2,2))
		fix_curr_ai = true


func _on_switch_ai_timeout():
	fix_curr_ai = false

func _physics_process(delta):
	ai_control()
	if self.position.distance_to(move_target) < 1: # Stop jittering when extremely close to target
		move_vec = Vector2.ZERO
	else:
		move_vec = self.position.direction_to(move_target)
	super(delta)
