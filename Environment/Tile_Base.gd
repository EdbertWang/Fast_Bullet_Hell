extends TileMap

enum tile_sets {
	DUNGEON,
	WORLD,
	TERRAIN,
}


# TODO: change tile sets depending on the biome

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

@onready var seen_chunks  = {}


const EXIT_TILE : Vector2i = Vector2i(4,0)


func _ready():
	#moisture.seed = randi()
	#temperature.seed = randi()
	#altitude.seed = randi()
	pass
	
func generate_chunk(curr_tile:Vector2, level_size: Vector2, camera_size: Vector2):
	var seeds : Array
	if curr_tile in seen_chunks:
		seeds = seen_chunks[curr_tile]
	else:
		seeds = [randi(),randi(),randi()]
		seen_chunks[curr_tile] = seeds
	
	moisture.seed = seeds[0]
	temperature.seed = seeds[1]
	altitude.seed = seeds[2]
	
	var xr = level_size.x
	var yr = level_size.y
	
	var cx = camera_size.x / 2
	var cy = camera_size.y / 2
	
	for x in range(xr):
		for y in range(yr):
			var moist = moisture.get_noise_2d(x,  y) * 10
			var temp = temperature.get_noise_2d(x, y) * 10
			var alt = altitude.get_noise_2d(x, y)
			set_cell(DataContainer.tile_layers.BACKGROUND,Vector2i(x - cx, y - cy), tile_sets.WORLD, Vector2i(round((moist + 10) / 5),round((temp + 10) / 5)))
	# Generate world borders
	for x in range(-1,xr+1):
		set_cell(DataContainer.tile_layers.BACKGROUND,Vector2i(x - cx, yr - cy),tile_sets.WORLD, EXIT_TILE)
		set_cell(DataContainer.tile_layers.BACKGROUND,Vector2i(x - cx, -cy - 1),tile_sets.WORLD, EXIT_TILE)
	for y in range(-1,yr+1):
		set_cell(DataContainer.tile_layers.BACKGROUND,Vector2i(xr - cx, y - cy),tile_sets.WORLD, EXIT_TILE)
		set_cell(DataContainer.tile_layers.BACKGROUND,Vector2i(-cx - 1, y - cy),tile_sets.WORLD, EXIT_TILE)
	
	gen_structures()
	
	return [moisture.seed, temperature.seed, altitude.seed]
	
func unload_chunk(level_size: Vector2, camera_size: Vector2):
	var xr = level_size.x
	var yr = level_size.y
	var cx = camera_size.x / 2
	var cy = camera_size.y / 2
	for x in range(xr):
		for y in range(yr):
			erase_cell(0,Vector2i(x - cx,y - cy))

func gen_structures(): # TODO:  determine what to generate
	for i in range(1):
		var pttrn = tile_set.get_pattern(0)
		set_pattern(0, Vector2i(10, 10), pttrn)
		pass

"""
@export var rooms_size : Vector2 = Vector2(10, 14)
@export var rooms_max : int = 15
func _generate():
	self.clear()
	for vector in _generate_data():
		self.set_cellv(vector, 0)
		
func _generate_data() -> Array:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var data := {}
	var rooms := []
	for r in range(rooms_max):
		var room := _get_random_room(rng)
		if _intersects(rooms, room):
			continue

		_add_room(data, rooms, room)
		if rooms.size() > 1:
			var room_previous: Rect2 = rooms[-2]
			_add_connection(rng, data, room_previous, room)
	return data.keys()

func _get_random_room(rng: RandomNumberGenerator) -> Rect2:
	var width := rng.randi_range(rooms_size.x, rooms_size.y)
	var height := rng.randi_range(rooms_size.x, rooms_size.y)
	var x := rng.randi_range(0, level_size.x - width - 1)
	var y := rng.randi_range(0, level_size.y - height - 1)
	return Rect2(x, y, width, height)
	
	
func _add_room(data: Dictionary, rooms: Array, room: Rect2) -> void:
	rooms.push_back(room)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			data[Vector2(x, y)] = null

func _add_connection(rng: RandomNumberGenerator, data: Dictionary, room1: Rect2, room2: Rect2) -> void:
	var room_center1 := (room1.position + room1.end) / 2
	var room_center2 := (room2.position + room2.end) / 2
	if rng.randi_range(0, 1) == 0:
		_add_corridor(data, room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)
	else:
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)
		_add_corridor(data, room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)

func _add_corridor(data: Dictionary, start: int, end: int, constant: int, axis: int) -> void:
	for t in range(min(start, end), max(start, end) + 1):
		var point := Vector2.ZERO
		match axis:
			Vector2.AXIS_X: point = Vector2(t, constant)
			Vector2.AXIS_Y: point = Vector2(constant, t)
		data[point] = null

func _intersects(rooms: Array, room: Rect2) -> bool:
	var out := false
	for room_other in rooms:
		if room.intersects(room_other):
			out = true
			break
	return out


"""	
