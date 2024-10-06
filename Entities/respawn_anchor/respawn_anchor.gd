extends Base_Unit

@onready var nav_obst : NavigationObstacle2D = $NavigationObstacle2D

signal respawn_anchor_break

func _ready():
	SIGNALS.add_emitter("respawn_anchor_break", self)


func emit_respawn_anchor_break():
	emit_signal("respawn_anchor_break")
