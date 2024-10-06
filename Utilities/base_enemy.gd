extends Base_Unit
class_name Enemy


const MAX_CHASE_DIST : int = 500

@onready var nav = get_node("NavigationAgent2D")
@onready var player = null #SINGLETONS.entity_base.get_node("Player")
@onready var path_timer = $Path_Timer
var curr_ai : Callable = Callable(self,"idle")

@onready var search_space = $SearchSpace # dict in_range shows what is in detection range


#@onready var orignal_position : Vector2
@export var spawn_cost : int

func do_nav() -> void:
	if not nav.is_target_reached():
		move_vec = nav.get_next_path_position() - global_position

	if move_vec.x < 0:
		sprite.flip_h = true
	elif move_vec.x > 0: 
		sprite.flip_h = false

func chase() -> void:
	if player:
		nav.target_position = player.position
	else: 
		nav.target_position = position
		
func idle() -> void:
	nav.target_position = position

func _on_path_timer_timeout(): # Every half a second will try to get location of the player and path towards them
	if is_instance_valid(player):
		curr_ai.call()
	else:
		nav.target_position = position

func is_close_to_player() -> bool: # Used by FSM to determine when to switch to a chasing state
	#print(search_space.in_range)
	for i in search_space.in_range.keys():
		if i.is_in_group("friendly"):
			player = i
			return true
	#player = null
	return false

func too_far_from_player() -> bool: # used by FSM to determine when to stop chasing
	if not player or position.distance_to(player.global_position) > MAX_CHASE_DIST:
		player = null
		return true
	return false

func spawn(unit_name: String, spawn_loc : Vector2, misc_args : Array) -> Array[Object]: # Will be overridden in chilren
	self.position = spawn_loc
	self.unit_name = unit_name
	var unit_info = DATABASE.ENEMIES[unit_name]
	
	# Lookup the entity's values in the data container
	self.max_hp = unit_info[DATABASE.get_enemy_property_index("MaxHP")]
	self.max_mana = unit_info[DATABASE.get_enemy_property_index("MaxMana")]
	self.mana_regen = unit_info[DATABASE.get_enemy_property_index("ManaRegen")]
	self.armor = unit_info[DATABASE.get_enemy_property_index("Armor")]
	self.base_speed = unit_info[DATABASE.get_enemy_property_index("MoveSpeed")]
	self.knock_back_recovery = unit_info[DATABASE.get_enemy_property_index("KnockBackRecovery")]

	self.move_speed  = base_speed
	self.curr_mana  = max_mana
	self.curr_hp = max_hp

	return [self]
