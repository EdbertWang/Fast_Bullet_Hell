extends TileMap

enum tile_sets {
	WORLD,
}
const CARDINALS : PackedVector2Array = [Vector2(-1,0),Vector2(1,0),Vector2(0,-1),Vector2(0,1)]
const EXIT_TILE : Vector2i = Vector2i(5,0)
"""
const LEFT_WALL : Vector2i = Vector2i(4,0)
const RIGHT_WALL : Vector2i = Vector2i(3,0)
const UP_WALL : Vector2i = Vector2i(2,0)
const DOWN_WALL : Vector2i = Vector2i(1,0)
"""

const WALL : Vector2i = Vector2i(0,1)

const FLOOR : Vector2i = Vector2i(0,0)
const MIN_SPAWN_DIST : int = 100

@onready var curr_chunk : Vector2 = Vector2(0,0)

@export var level_size : Vector2 = Vector2(100,100)
#@export var camera_size : Vector2 = Vector2(100,100)

@export var room_max_size : Vector2 = Vector2(29, 29)
@export var room_min_size : Vector2 = Vector2(9,9)
@export var room_max : int = 15

@onready var seen_chunks  = {}

@onready var curr_tileset : int = tile_sets.WORLD # TODO: change tile sets depending on the biome

# Current Level information
var rooms = []
var spawn_zones = []
var player_spawn = []
var map = []


func generate_chunk(curr_tile:Vector2):
	# TODO: Save all the tiles when generated, then place all those tiles when seen
	
	var xr = level_size.x
	var yr = level_size.y
	
	#var cx = camera_size.x / 2
	#var cy = camera_size.y / 2
	
	for x in range(level_size.x):
		map.append([])
		for y in range(level_size.y):
			map[x].append(0)

	# Try to partition the free space in the level into a series of rooms
	var free_regions = [Rect2(Vector2(2, 2), level_size - Vector2(4, 4))]
	for i in range(room_max):
		add_room(free_regions)
		if free_regions.size() == 0:
			break
	
	# Create 3 Tile wide corridors from random rooms, until all rooms are reachable
	connect_rooms()
	
	# Generate Paths to borders
	create_paths_to_borders()

	# Generate world borders
	for x in range(-1,xr+1):
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(x, yr),curr_tileset, EXIT_TILE)
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(x, - 1),curr_tileset, EXIT_TILE)
	for y in range(-1,yr+1):
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(xr , y ),curr_tileset, EXIT_TILE)
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(- 1, y ),curr_tileset, EXIT_TILE)
	

	
	gen_walls()
	gen_structures()
	create_spawns()
	
	save_chunk()
	
func unload_chunk():
	clear()
	rooms.clear()
	spawn_zones.clear()
	map.clear()

func save_chunk(): # TODO : Determine how we want to save the tiles, probably just a 2d array of tile numbers
	pass

func gen_structures(): # TODO:  determine what to generate
	if curr_chunk == Vector2.ZERO:
		# Spawn the necessary structures for the spawn tile
		pass
	for i in range(1):
		var pttrn = tile_set.get_pattern(0)
		set_pattern(0, Vector2i(10, 10), pttrn)
		pass

func gen_walls():
	# Loop through all the tiles in the tilemap
	for x in range(level_size.x):
		for y in range(level_size.y):
			var tile_pos = Vector2i(x, y)
			var current_tile = get_cell_source_id(DATABASE.tile_layers.BACKGROUND, tile_pos)

			# Check if the current tile is empty (not a floor or wall)
			if current_tile == -1:  # Assuming -1 means empty
				# Check surrounding tiles
				for direction in CARDINALS:
					var neighbor_pos = tile_pos + Vector2i(direction)
					var neighbor_tile = get_cell_atlas_coords(DATABASE.tile_layers.BACKGROUND, neighbor_pos)
					
					# If any surrounding tile is a floor, set this tile to a wall
					if neighbor_tile == Vector2i(FLOOR):
						set_cell(DATABASE.tile_layers.BACKGROUND, tile_pos, curr_tileset, WALL)
						break  # No need to check further if one neighbor is a floor


func add_room(free_regions):
	var region = free_regions[randi() % free_regions.size()]
		
	var size_x : int = int(room_min_size.x)
	if region.size.x > room_min_size.x:
		size_x += randi() % int(region.size.x - room_min_size.x)
		# Ensure size_x is odd
		if size_x % 2 == 0:
			size_x += 1

	var size_y : int = int(room_min_size.y)
	if region.size.y > room_min_size.y:
		size_y += randi() % int(region.size.y - room_min_size.y)
		# Ensure size_y is odd
		if size_y % 2 == 0:
			size_y += 1
		
	size_x = min(size_x, room_max_size.x)
	size_y = min(size_y, room_max_size.y)
		
	# Generate an random starting point for hte rectangle
	var start_x = region.position.x
	if region.size.x > size_x:
		start_x += randi() % int(region.size.x - size_x)
		
	var start_y = region.position.y
	if region.size.y > size_y:
		start_y += randi() % int(region.size.y - size_y)
	
	var room = Rect2(start_x, start_y, size_x, size_y)
	rooms.append(room)
	set_room_tiles(room)
	cut_regions(free_regions, room)

func cut_regions(free_regions, region_to_remove):
	var removal_queue = []
	var addition_queue = []
	
	for region in free_regions:
		if region.intersects(region_to_remove):
			removal_queue.append(region)
			
			var leftover_left = region_to_remove.position.x - region.position.x - 1
			var leftover_right = region.end.x - region_to_remove.end.x - 1
			var leftover_above = region_to_remove.position.y - region.position.y - 1
			var leftover_below = region.end.y - region_to_remove.end.y - 1
			
			if leftover_left >= room_max_size.x:
				addition_queue.append(Rect2(region.position, Vector2(leftover_left, region.size.y)))
			if leftover_right >= room_max_size.x:
				addition_queue.append(Rect2(Vector2(region_to_remove.end.x + 1, region.position.y), Vector2(leftover_right, region.size.y)))
			if leftover_above >= room_max_size.x:
				addition_queue.append(Rect2(region.position, Vector2(region.size.x, leftover_above)))
			if leftover_below >= room_max_size.x:
				addition_queue.append(Rect2(Vector2(region.position.x, region_to_remove.end.y + 1), Vector2(region.size.x, leftover_below)))
				
	for region in removal_queue:
		free_regions.erase(region)
		
	for region in addition_queue:
		free_regions.append(region)


func set_room_tiles(room : Rect2):
	# Set Center
	for i in range(room.size.x):
		for j in range(room.size.y):
			set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(room.position.x + i, room.position.y + j), curr_tileset, FLOOR)
	
	# Set Top and Bottom Walls
	for i in range(room.size.x):
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(room.position.x + i, room.position.y), curr_tileset, WALL)
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(room.position.x + i, room.position.y + room.size.y), curr_tileset, WALL)
	# Set Left and Right Walls
	for i in range(room.size.y):
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(room.position.x, room.position.y + i), curr_tileset, WALL)
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(room.position.x + room.size.x, room.position.y + i), curr_tileset, WALL)


func connect_rooms():
	# Create AStar graphs for space and rooms
	var space_graph = AStar2D.new()
	var room_graph = AStar2D.new()

	# Add available space points to the space graph
	var point_id = 0
	for x in range(level_size.x):
		for y in range(level_size.y):
			if map[x][y] == 0:
				space_graph.add_point(point_id, Vector2(x, y))
				if x > 0 and map[x - 1][y] == 0:
					space_graph.connect_points(point_id, space_graph.get_closest_point(Vector2(x - 1, y)))
				if y > 0 and map[x][y - 1] == 0:
					space_graph.connect_points(point_id, space_graph.get_closest_point(Vector2(x, y - 1)))
				point_id += 1

	# Add rooms to the room graph
	point_id = 0
	for room in rooms:
		var room_center = room.position + room.size / 2
		room_graph.add_point(point_id, Vector2(room_center.x, room_center.y))
		point_id += 1

	# Try to connect rooms
	var max_attempts = 10
	while not is_everything_connected(room_graph):
		var connected = add_random_connection(space_graph, room_graph)
		if not connected:
			max_attempts -= 1
			if max_attempts == 0:
				print("Unable to fully connect rooms, but rooms are connected.")
				break

		# Stop further connection attempts once rooms are connected
		if is_everything_connected(room_graph):
			print("All rooms successfully connected.")
			break



func is_everything_connected(graph: AStar2D) -> bool:
	var points = graph.get_point_ids()
	if points.size() == 0:
		return false
	
	var start = points[0]
	for point in points:
		# Use get_point_path to check if the points are connected by a path
		if graph.get_point_path(start, point).size() == 0:
			return false
	
	return true


func add_random_connection(space_graph, room_graph) -> bool:
	# Pick rooms to connect
	var start_room_id = get_least_connected_point(room_graph)
	var end_room_id = get_nearest_unconnected_point(room_graph, start_room_id)
	
	# If no room was found to connect, return false
	if end_room_id == null:
		# Only print this if we're genuinely unable to connect
		print("Unable to find a suitable room to connect.")
		return false
	
	# Generate path between the two rooms
	generate_path(room_graph.get_point_position(start_room_id), room_graph.get_point_position(end_room_id))
	
	# Connect the rooms in the graph
	room_graph.connect_points(start_room_id, end_room_id)
	return true

func generate_path(start: Vector2, end: Vector2):
	var current_point = start
	
	# Vertical path
	var step = sign(end.y - start.y)
	while current_point.y != end.y:
		# Create 3-block wide path
		set_cell(DATABASE.tile_layers.BACKGROUND, Vector2i(current_point + Vector2(-1, 0)), curr_tileset, FLOOR)
		set_cell(DATABASE.tile_layers.BACKGROUND, Vector2i(current_point), curr_tileset, FLOOR)
		set_cell(DATABASE.tile_layers.BACKGROUND, Vector2i(current_point + Vector2(1, 0)), curr_tileset, FLOOR)
		
		current_point += Vector2(0, 1) * step

	# Horizontal path
	step = sign(end.x - start.x)
	while current_point.x != end.x:
		# Create 3-block wide path
		set_cell(DATABASE.tile_layers.BACKGROUND, Vector2i(current_point + Vector2(0, -1)), curr_tileset, FLOOR)
		set_cell(DATABASE.tile_layers.BACKGROUND, Vector2i(current_point), curr_tileset, FLOOR)
		set_cell(DATABASE.tile_layers.BACKGROUND, Vector2i(current_point + Vector2(0, 1)), curr_tileset, FLOOR)
		
		current_point += Vector2(1, 0) * step



func get_least_connected_point(graph):
	var point_ids = graph.get_point_ids()
	
	var least = 1000
	var tied_for_least = []
	
	for point in point_ids:
		var count = graph.get_point_connections(point).size()
		if count < least:
			least = count
			tied_for_least = [point]
		elif count == least:
			tied_for_least.append(point)
			
	return tied_for_least[randi() % tied_for_least.size()]
	
func get_nearest_unconnected_point(graph, target_point):
	var target_position = graph.get_point_position(target_point)
	var point_ids = graph.get_point_ids()
	
	var nearest  = 1000
	var tied_for_nearest = []
	
	for point in point_ids:
		if point == target_point:
			continue
		
		# Check if a path to this point already exists
		if graph.get_point_path(point, target_point):
			continue
			
		var dist = (graph.get_point_position(point) - target_position).length()
		if dist < nearest:
			nearest = dist
			tied_for_nearest = [point]
		elif dist == nearest:
			tied_for_nearest.append(point)
			
	if tied_for_nearest.size() == 0:
		return null
	return tied_for_nearest[randi() % tied_for_nearest.size()]

func create_spawns(): # Generate potential locations for where enemies are allows to spawn
	for i in rooms:
		var curr_spawns = []
		for j in range(10): # Make 10 attempts to create spawn zones
			var potential_loc : Vector2 = i.position + Vector2(randi_range(0,i.size.x),randi_range(0,i.size.y))
			var can_add_spawn : bool = true
			for k in curr_spawns:
				if potential_loc.distance_to(k) < MIN_SPAWN_DIST:
					can_add_spawn = false
					break
			if can_add_spawn:
				spawn_zones.append(potential_loc * Vector2(tile_set.tile_size))

func player_touch_border(player_position : Vector2) -> Vector2:
	var tile_limits : Vector2 = Vector2(tile_set.tile_size.x * level_size.x,tile_set.tile_size.y * level_size.y)
	var tile_size_1d : int = tile_set.tile_size.x
	if curr_chunk == Vector2(0,0): # Default spawn
		return Vector2(level_size.x/2 * tile_size_1d,level_size.y/2 * tile_size_1d)
	else: # Player is moving into another tile from a cardinal path
		if (player_position.x >= tile_limits.x):
			return Vector2((level_size.x - 1) * tile_size_1d, player_position.y)
		elif (player_position.x <= 0):
			return Vector2(1, player_position.y)
		elif (player_position.y >= tile_limits.y):
			return Vector2(player_position.x, 1)
		elif (player_position.y <= 0):
			return Vector2(player_position.x, (level_size.y - 1) * tile_size_1d)
	
	return Vector2(level_size.x/2,level_size.y/2)

func find_closest_room(target_pos: Vector2i) -> Rect2:
	var closest_room : Rect2
	var shortest_distance = 10000
	
	for room in rooms:
		var room_center = room.position + room.size / 2
		var distance = room_center.distance_to(target_pos)
		
		if distance < shortest_distance:
			shortest_distance = distance
			closest_room = room
	
	return closest_room


func create_paths_to_borders():
	# Define border locations and their labels
	var borders = {
		"left": Vector2i(-1, level_size.y / 2),
		"right": Vector2i(level_size.x, level_size.y / 2),
		"top": Vector2i(level_size.x / 2, -1),
		"bottom": Vector2i(level_size.x / 2, level_size.y)
	}
	
	# Loop through each border and create the path to the closest room
	for border_name in borders.keys():
		var border_pos = borders[border_name]
		var closest_room = find_closest_room(border_pos)
		
		if closest_room:
			var room_center = closest_room.position + closest_room.size / 2
			generate_path(Vector2i(room_center), border_pos)
