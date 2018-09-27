extends Position2D

onready var player = $".."
onready var offset = Vector2(0, 10)
# TODO: Implement "action" camera

func _ready():
	pass

func _process(delta):
	var pos = (get_global_mouse_position() + player.global_position)/4
	global_position = pos

func update_pivot_angle():
	pass