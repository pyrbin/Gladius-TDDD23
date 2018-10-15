extends Position2D

onready var player = $".."

const CAMERA_MAX_MARGIN = 60
const CAMERA_DEAD_MARGIN = 30

func _ready():
	pass

func _process(delta):

	var p_pos = player.global_position
	var m_pos = get_global_mouse_position()
	var m_dir = utils.dir_from(player.global_position, m_pos)
	var max_pos = player.global_position + (m_dir * CAMERA_MAX_MARGIN)


	if p_pos.distance_to(m_pos) <= CAMERA_MAX_MARGIN:
		global_position = m_pos
	else:
		global_position = max_pos
