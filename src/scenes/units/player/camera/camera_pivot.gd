extends Position2D

onready var player = $".."

# TODO: Implement "action" camera

func _ready():
	pass

func _process(delta):
	var mouse_pos = get_global_mouse_position()

func update_pivot_angle():
	pass