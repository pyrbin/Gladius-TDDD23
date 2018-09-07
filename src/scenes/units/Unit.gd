# Interface class for game units

extends KinematicBody2D

export (int) var speed = 200

enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}
const UNIT_DRAW_LAYER = 1

onready var health = $Health
var look_state = TOP_RIGHT
var look_position = Vector2(0,0)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$BodyPivot/Body.z_index = UNIT_DRAW_LAYER
	pass

func get_movement_direction():
	pass

func get_aim_position():
	pass

func _set_look_state (look_position):
	var body_global_pos = $BodyPivot/Body.global_position
	if look_position.x > body_global_pos.x:
		look_state = BOTTOM_RIGHT if look_position.y > body_global_pos.y else TOP_RIGHT
	else:
		look_state = BOTTOM_LEFT if look_position.y > body_global_pos.y else TOP_LEFT

func set_dead(value):
	set_process_input(not value)
	set_physics_process(not value)

func _physics_process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	_set_look_state(get_aim_position())
	pass
	
