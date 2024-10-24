extends Tile_Effects

func apply_tile_effect(tile_type : String):
	match tile_type:
		"exit":
			var tile_limits : int = SINGLETONS.tile_base.tile_set.tile_size.x * SINGLETONS.tile_base.level_size.x
			#print(position)
			#print(tile_limits)
			if (get_parent().position.x > tile_limits):
				SINGLETONS.world.move_chunk(Vector2(1,0))
				get_parent().GUI_node.move_minimap(Vector2(1,0))
			elif (get_parent().position.x < 0):
				SINGLETONS.world.move_chunk(Vector2(-1,0))
				get_parent().GUI_node.move_minimap(Vector2(-1,0))
			elif (get_parent().position.y > tile_limits):
				SINGLETONS.world.move_chunk(Vector2(0,1))
				get_parent().GUI_node.move_minimap(Vector2(0,1))
			elif (get_parent().position.y < 0):
				SINGLETONS.world.move_chunk(Vector2(0,-1))
				get_parent().GUI_node.move_minimap(Vector2(0,-1))
			get_parent().global_position = SINGLETONS.tile_base.player_touch_border(get_parent().global_position)
			return
	super(tile_type) # Do a default action if not specificly matched
