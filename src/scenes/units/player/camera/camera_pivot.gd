extends Position2D

onready var player = $".."

func _ready():
	pass

func _process(delta):
	var pos = (get_global_mouse_position() + player.global_position)
	global_position = player.global_position