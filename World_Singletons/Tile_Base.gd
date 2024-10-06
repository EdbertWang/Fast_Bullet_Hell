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
@export var camera_size : Vector2 = Vector2(100,100)

@export var room_max_size : Vector2 = Vector2(15, 15)
@export var room_min_size : Vector2 = Vector2(9, 9)
@export var room_max : int = 15

@onready var seen_chunks  = {}

@onready var curr_tileset : int = tile_sets.WORLD

# Current Level information
var rooms = []
var spawn_zones = []
var map = []
# TODO: change tile sets depending on the biome

func generate_chunk(curr_tile:Vector2):
	# TODO: Save all the tiles when generated, then place all those tiles when seen
	
	var xr = level_size.x
	var yr = level_size.y
	
	var cx = camera_size.x / 2
	var cy = camera_size.y / 2
	
	for x in range(level_size.x):
		map.append([])
		for y in range(level_size.y):
			map[x].append(0)

	var free_regions = [Rect2(Vector2(2, 2), level_size - Vector2(4, 4))]
	for i in range(room_max):
		add_room(free_regions)
		if free_regions.size() == 0:
			break
	
	connect_rooms()

	# Generate world borders
	for x in range(-1,xr+1):
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(x, yr),curr_tileset, EXIT_TILE)
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(x, - 1),curr_tileset, EXIT_TILE)
	for y in range(-1,yr+1):
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(xr , y ),curr_tileset, EXIT_TILE)
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(- 1, y ),curr_tileset, EXIT_TILE)
	
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

func gen_walls(): # TODO: Set the wall tiles. Use one single wall type for simplicity
	pass

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
	# Build an AStar graph of the area where we can add corridors
	var space_graph = AStar2D.new()
	var point_id = 0
	for x in range(level_size.x):
		for y in range(level_size.y):
			if map[x][y] == 0:
				space_graph.add_point(point_id, Vector2(x, y))
				
				# Connect to left if also available
				if x > 0 && map[x - 1][y] == 0:
					var left_point = space_graph.get_closest_point(Vector2(x - 1, y))
					space_graph.connect_points(point_id, left_point)
					
				# Connect to above if also available
				if y > 0 && map[x][y - 1] == 0:
					var above_point = space_graph.get_closest_point(Vector2(x, y - 1))
					space_graph.connect_points(point_id, above_point)
					
				point_id += 1

	# Build an AStar graph of room connections
	var room_graph = AStar2D.new()
	point_id = 0
	for room in rooms:
		var room_center = room.position + room.size / 2
		room_graph.add_point(point_id, Vector2(room_center.x, room_center.y))
		point_id += 1
	
	# Add random connections until everything is connected
	while not is_everything_connected(room_graph):
		if not add_random_connection(space_graph, room_graph):
			break


func is_everything_connected(graph):
	var points = graph.get_point_ids()
	var start = points[0]
	for point in points:
		if not graph.are_points_connected(start,point):
			return false
	return true
	
func add_random_connection(space_graph, room_graph) -> bool:
	# Pick rooms to connect
	var start_room_id = get_least_connected_point(room_graph)
	var end_room_id = get_nearest_unconnected_point(room_graph, start_room_id)
	
	if not end_room_id: return false
	
	generate_path(room_graph.get_point_position(start_room_id),room_graph.get_point_position(end_room_id))
	
	room_graph.connect_points(start_room_id, end_room_id)
	return true


func generate_path(start: Vector2, end: Vector2):
	
	var current_point = start
	
	# Vertical path
	var step = sign(end.y - start.y)
	while current_point.y != end.y:
		current_point += Vector2(0,1) * step
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(current_point), curr_tileset, FLOOR)
		

	# Horizontal path
	step = sign(end.x - start.x)
	while current_point.x != end.x:
		current_point += Vector2(1,0) * step
		set_cell(DATABASE.tile_layers.BACKGROUND,Vector2i(current_point), curr_tileset, FLOOR)


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
				spawn_zones.append(potential_loc)
