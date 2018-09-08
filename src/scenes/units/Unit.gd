# Interface class for game units
extends KinematicBody2D

export (String) var weapon_path = "res://scenes/weapons/swing_weapon/SwingWeapon.tscn"

const UNIT_DRAW_LAYER = 6
const SHADOW_DRAW_LAYER = 4

enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}

onready var shadow = $Shadow
onready var health = $Health
onready var weapon_pivot = $BodyPivot/WeaponPivot
onready var body = $BodyPivot/Body

var weapon
var look_state = TOP_RIGHT
var look_position = Vector2(0,0)

func _ready():
    body.z_index = UNIT_DRAW_LAYER
    shadow.z_index = SHADOW_DRAW_LAYER
    var wep = load(weapon_path)
    var wep_inst = wep.instance()
    weapon_pivot.add_child(wep_inst)
    weapon = weapon_pivot.get_child(0)

func get_movement_direction():
    pass

func left_attack_weapon():
    weapon.attack();

func is_weapon_ready():
    return weapon.attack_state == weapon.ATTACK_STATE.IDLE

func get_aim_position():
    pass

func _set_look_state(look_position):
    if look_position.x > body.global_position.x:
        look_state = BOTTOM_RIGHT if look_position.y > body.global_position.y else TOP_RIGHT
    else:
        look_state = BOTTOM_LEFT if look_position.y > body.global_position.y else TOP_LEFT
    
    if is_weapon_ready():
        weapon_pivot.look_at(get_aim_position())
    

func set_dead(value):
    set_process_input(not value)
    set_physics_process(not value)

func _physics_process(delta):
    _set_look_state(get_aim_position())
