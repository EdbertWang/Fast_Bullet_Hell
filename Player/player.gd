extends "res://Utilities/Base_Unit.gd"

# GUI
#@onready var expBar = get_node("%EXP_Bar")
#@onready var level_label = get_node("%Level_label")
#@onready var healthBar = get_node("%HealthBar")

func _ready():
	print("Calling player ready")
	#abilities.append(Ability_Info.new("Sword", 1))
	abilities.append(Ability_Info.new("Firebolt", 1))

func _physics_process(delta):
	player_movement()
	super(delta)
	shoot()
	
func player_movement():
	var xmov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var ymov = Input.get_action_strength("down") - Input.get_action_strength("up")

	move_vec = Vector2(xmov,ymov)
func shoot():
	if Input.is_action_pressed("click"):
		var mouse_pos = get_viewport().get_mouse_position()
		if mouse_pos.x < position.x:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
		for i in range(ability_scene.size()):
			use_ability(i)

func apply_tile_effect(tile_type : int):
	match tile_type:
		0:
			var tile_limits : int = world.tile_base.tile_set.tile_size.x * world.level_size.x / 2
			#print(position)
			#print(tile_limits)
			if (position.x > tile_limits):
				world.create_new_chunk(Vector2(1,0))
				$GUI/Control/Minimap.moveMap(Vector2(1,0))
				position.x -= tile_limits * 1.9
			elif (position.x < -tile_limits):
				world.create_new_chunk(Vector2(-1,0))
				$GUI/Control/Minimap.moveMap(Vector2(-1,0))
				position.x += tile_limits * 1.9
			elif (position.y > tile_limits):
				world.create_new_chunk(Vector2(0,1))
				$GUI/Control/Minimap.moveMap(Vector2(0,1))
				position.y -= tile_limits * 1.9
			elif (position.y < -tile_limits):
				world.create_new_chunk(Vector2(0,-1))
				$GUI/Control/Minimap.moveMap(Vector2(0,-1))
				position.y += tile_limits * 1.9
			return
	super(tile_type)

