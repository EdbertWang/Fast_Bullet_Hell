extends Node2D

class_name Tile_Effects

@onready var tick_rate : Timer = $Tick_Rate
var prev_type : String = ""
var can_tick : bool = true

func get_tile_data_at(tile_position: Vector2) -> TileData:
	return SINGLETONS.tile_base.get_cell_tile_data(DATABASE.tile_layers.BACKGROUND, SINGLETONS.tile_base.local_to_map(tile_position))


func get_custom_data_at(tile_position: Vector2, custom_data_name: String) -> Variant:
	var data = get_tile_data_at(tile_position)
	if (data == null): return ""
	return data.get_custom_data(custom_data_name)

func apply_tile_effect(tile_type : String): # For this use the most generic tile effects, override in each entity 
	match tile_type: # TODO: have default behaviors for tiles here
		"exit":
			pass

func _physics_process(_delta):
	#print("asdfasd")
	var curr_type = get_custom_data_at(global_position,"TerrainType")
	if can_tick or curr_type != prev_type:
		if curr_type != prev_type:
			prev_type = curr_type
		apply_tile_effect(curr_type)
		can_tick = false
		#tick_rate.start()


func _on_tick_rate_timeout():
	can_tick = true
