# Interface class for game units
extends KinematicBody2D

const UNIT_DRAW_LAYER = 2
const SHADOW_DRAW_LAYER = 1

enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}

onready var body = $BodyPivot/Body
onready var shadow = $Shadow
onready var health = $Health

var look_state = TOP_RIGHT
var look_position = Vector2(0,0)

func _ready():
    body.z_index = UNIT_DRAW_LAYER
    shadow.z_index = SHADOW_DRAW_LAYER

func get_movement_direction():
    pass

func get_aim_position():
    pass

func _set_look_state (look_position):
    if look_position.x > body.global_position.x:
        look_state = BOTTOM_RIGHT if look_position.y > body.global_position.y else TOP_RIGHT
    else:
        look_state = BOTTOM_LEFT if look_position.y > body.global_position.y else TOP_LEFT

func set_dead(value):
    set_process_input(not value)
    set_physics_process(not value)

func _physics_process(delta):
    _set_look_state(get_aim_position())
    
