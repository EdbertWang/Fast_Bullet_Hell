extends Base_Unit

# GUI
@onready var GUI_node = get_node("GUI")
#@onready var expBar = get_node("%EXP_Bar")
#@onready var level_label = get_node("%Level_label")
#@onready var healthBar = get_node("%HealthBar")

# Basic Attack
@onready var basic_attack : PackedScene = preload("res://Entities/Player/player_attack.tscn")
var can_shoot : bool = true
@onready var basic_attack_timer : Timer = $Basic_Attack_Timer

# Abilites Code
var ability_indicies : Dictionary
@export var abilities : Array[Ability_Info]
var ability_scene : Array[Object]
var ability_cooldowns : Array[Timer]

signal respawn_player
@onready var can_respawn : bool = true

signal player_died

func _ready():
	print("Calling player ready")
	#abilities.append(Ability_Info.new("Sword", 1))
	abilities.append(Ability_Info.new("Firebolt", 1))
	
	# Connecting Global Signals
	SIGNALS.add_listener("respawn_anchor_break",self,"no_respawn")


func get_mouse_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()

func get_move_input():
	var xmov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var ymov = Input.get_action_strength("down") - Input.get_action_strength("up")

	if xmov < 0:
		sprite.flip_h = true
	elif xmov > 0:
		sprite.flip_h = false
	move_vec = Vector2(xmov,ymov)
	
func shoot():
	if Input.is_action_pressed("click"):
		var mouse_pos = get_viewport().get_mouse_position()
		
		if mouse_pos.x < position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
		if can_shoot:
			mouse_pos = get_local_mouse_position()
			var basic_attack_inst = basic_attack.instantiate()
			basic_attack_inst.position = global_position
			basic_attack_inst.direction = mouse_pos.normalized()
			basic_attack_inst.rotation = mouse_pos.angle()
			
			basic_attack_inst.speed = 150
			
			SINGLETONS.proj_base.add_child(basic_attack_inst)
			
			can_shoot = false
			basic_attack_timer.start()


func _on_basic_attack_timer_timeout():
	can_shoot = true


func reload_abilities():
	#print("Loading abilites for ", self)
	ability_scene.clear()
	for i in ability_cooldowns:
		i.queue_free()
	ability_cooldowns.clear()
	for i in range(abilities.size()):
		#print("Adding " + abilities[i].name)
		ability_scene.append(load_ability(abilities[i].name))
		var timer = Timer.new()
		timer.wait_time = abilities[i].cooldown
		timer.timeout.connect(abilities[i]._timer_timeout)
		timer.one_shot = true
		add_child(timer)
		ability_cooldowns.append(timer)

func use_ability(index : int):
	if not abilities[index].on_cd and curr_mana >= abilities[index].mana_cost:
		ability_scene[index].execute(self)
		abilities[index]._start_cd()
		ability_cooldowns[index].start()
		curr_mana -= abilities[index].mana_cost

func post_load():
	reload_abilities()


func load_ability(ability_name : String): # Add possible abilites to in_proj_base and proj_base
	pass
	"""
	if ability_name not in in_proj_base:
		print("Loading new projectile ", ability_name)
		var scene = load("res://Abilities/" + ability_name + "/" + ability_name + ".tscn")
		var scenenode = scene.instantiate()
		in_proj_base[ability_name] = 1
		proj_base.add_child(scenenode)
		return scenenode
	else:
		print("Projectile Already in Base ", ability_name)
		in_proj_base[ability_name] += 1
		return proj_base.find_child(ability_name,false,false)
	"""

func respawn_func():
	if can_respawn:
		emit_signal("respawn")
		curr_hp = max_hp
		curr_mana = max_mana
		
		# World space call handles moving tile and player location
		var chunk_pos = SINGLETONS.tile_base.curr_chunk
		position = SINGLETONS.tile_base.level_size/2
		SINGLETONS.world.move_chunk(-chunk_pos)
		GUI_node.move_minimap(-chunk_pos)
		
	else:
		emit_signal("player_died")
		queue_free()
	
func no_respawn():
	can_respawn = false
