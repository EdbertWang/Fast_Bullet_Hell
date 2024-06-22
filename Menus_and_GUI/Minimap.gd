extends MarginContainer

@onready var MapNodes = $MarginContainer/BackGround

@export var tileIconSize : Vector2 = Vector2(20,20)
#@export var mapSize : Vector2 = Vector2(5,5)

# World gen will create grayed frames
func _ready():
	await get_tree().process_frame
	setup()
	setVisibility()

func setup(): # TODO: get thr changin coloring for visited nodes to work
	#var center : Vector2 =  Vector2(0,0)
	var center : Vector2 =  MapNodes.size / 2
	for i in range(2 * DataContainer.mapSize.x + 1):
		for j in range(2 * DataContainer.mapSize.y + 1):
			var c = ColorRect.new()
			c.size = tileIconSize
			c.position = center + (i - DataContainer.mapSize.x) * tileIconSize * Vector2(1,0)  + (j - DataContainer.mapSize.y) * tileIconSize * Vector2(0,1)
			var colorVals =  DataContainer.BIOME_GRID[i][j]
			c.color = Color8(colorVals[0],colorVals[1],colorVals[2])
			#c.color.darkened(1)
			MapNodes.add_child(c)

func moveMap(move : Vector2):
	for c in MapNodes.get_children():
		c.position -= move * tileIconSize
	setVisibility()

func setVisibility():
	for c in MapNodes.get_children():
		if c.position.x + tileIconSize.x > MapNodes.size.x or c.position.y + tileIconSize.y > MapNodes.size.y or c.position.x < 0 or c.position.y < 0:
			c.visible = false
		else:
			c.visible = true
