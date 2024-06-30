extends CharacterBody2D

@onready var sprite = $Sprite2D
@onready var coll = $CollisionShape2D
@onready var animation = $AnimationPlayer
var unit_name : String

@export var abilities : Array[Ability_Info]
var ability_scene : Array[Object]
var ability_cooldowns : Array[Timer]
var world = null # Will be world space refernce - not sure if necessary

@export var max_hp : int
@onready var curr_hp : int = max_hp
@export var max_mana : int
@export var mana_regen : int
@onready var curr_mana : int = max_mana
@export var armor : int
@export var base_speed : int
@onready var move_speed : float = base_speed
@export var knock_back_recovery : float
@onready var move_vec : Vector2 = Vector2.ZERO
@onready var knock_back_applied : Vector2 = Vector2.ZERO

signal remove_from_world(object)

func get_tile_data_at(position: Vector2) -> TileData:
	return world.tile_base.get_cell_tile_data(DataContainer.tile_layers.BACKGROUND, world.tile_base.local_to_map(position))


func get_custom_data_at(position: Vector2, custom_data_name: String) -> Variant:
	var data = get_tile_data_at(position)
	if (data == null): return -1
	return data.get_custom_data(custom_data_name)

func _physics_process(_delta):
	apply_tile_effect(get_custom_data_at(position, "TerrainType"))
	
	velocity = move_vec.normalized() * move_speed # delta not needed since move and slide already factors in time 
	knock_back_applied = knock_back_applied.move_toward(Vector2.ZERO, knock_back_recovery)
	velocity += knock_back_applied
	if move_vec != Vector2.ZERO:
		if move_vec.x > 0: # All sprites should face right at the beginning
			sprite.flip_h = false
		elif move_vec.x < 0: 
			sprite.flip_h = true
		if not animation.is_playing():
			animation.play("walk")
	else:
		if animation.is_playing():
			animation.stop()
	#print(move_speed)
	#print(velocity)
	#print(self," ",move_vec)
	move_and_slide()

func _on_hurt_box_hurt(damage: int, angle: Vector2, knockback : float):
	print("Hurt Box Triggered ", damage," ", angle ," ", knockback," ")
	knock_back_applied = angle * knockback
	curr_hp -= clamp(damage - armor, 1, 9999)
	if curr_hp <= 0:
		death()
	
func death():
	emit_signal("remove_from_world",self)
	call_deferred("queue_free")

func reload_abilities():
	print("Loading abilites for ", self)
	ability_scene.clear()
	for i in ability_cooldowns:
		i.queue_free()
	ability_cooldowns.clear()
	for i in range(abilities.size()):
		print("Adding " + abilities[i].name)
		ability_scene.append(world.load_ability(abilities[i].name))
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

# Setup that occurs after the world scene is fully loaded
func post_load():
	if world == null:
		world = get_tree().get_first_node_in_group("world")
		reload_abilities()

func apply_tile_effect(tile_type : int):
	#print(tile_type)
	match tile_type:
		1:
			pass # TODO: 
		2:
			move_speed = base_speed / 1.5
		3: 
			move_speed = base_speed / 2.5
		_:
			move_speed = base_speed
	#print(move_speed)

func get_save_data():
	return {"unit_name": self.unit_name,"position" : self.position, "curr_hp" : self.curr_hp, "curr_mana" : self.curr_mana}

func set_properties(args_dict):
	unit_name = args_dict["unit_name"]
	position = args_dict["position"]
	curr_hp = args_dict["curr_hp"]
	curr_mana = args_dict["curr_mana"]
	
	
func spawn(unit_name: String, spawn_loc : Vector2, misc_args : Array) -> Array[Object]: # Will be overridden in chilren
	self.position = spawn_loc
	self.unit_name = unit_name
	var unit_info = DataContainer.ENEMIES[unit_name]
	
	# Lookup the entity's values in the data container
	self.max_hp = unit_info[DataContainer.get_enemy_property_index("MaxHP")]
	self.max_mana = unit_info[DataContainer.get_enemy_property_index("MaxMana")]
	self.mana_regen = unit_info[DataContainer.get_enemy_property_index("ManaRegen")]
	self.armor = unit_info[DataContainer.get_enemy_property_index("Armor")]
	self.base_speed = unit_info[DataContainer.get_enemy_property_index("MoveSpeed")]
	self.knock_back_recovery = unit_info[DataContainer.get_enemy_property_index("KnockBackRecovery")]

	self.move_speed  = base_speed
	self.curr_mana  = max_mana
	self.curr_hp = max_hp
	
	# Get its abilites into the array
	for key in unit_info[unit_info.size() - 2]: # TODO: May have to update if location of abilities dict changes location
		abilities.append(Ability_Info.new(key))

	return [self]
