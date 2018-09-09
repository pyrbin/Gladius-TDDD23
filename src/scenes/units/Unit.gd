# Interface class for game units
extends KinematicBody2D

signal unit_collided

export (String) var weapon_path = "res://scenes/weapons/swing_weapon/SwingWeapon.tscn"

const UNIT_DRAW_LAYER = 6
const SHADOW_DRAW_LAYER = 1

enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}

onready var shadow = $Shadow
onready var health = $Health
onready var weapon_pivot = $BodyPivot/WeaponPivot
onready var u_hand = $BodyPivot/U_Hand
onready var l_hand = $BodyPivot/L_Hand
onready var body = $BodyPivot/Body

var weapon
var look_state = TOP_RIGHT
var look_position = Vector2(0,0)
var velocity = Vector2(0,0)

func _ready():
    body.z_index = UNIT_DRAW_LAYER
    shadow.z_index = SHADOW_DRAW_LAYER
    equip_weapon(weapon_path)

func equip_weapon(wep_path):
    weapon_pivot.add_child(load(weapon_path).instance())
    weapon = weapon_pivot.get_child(0)
    reparent_hands()

func reparent_hands():
    $BodyPivot.remove_child(u_hand)
    $BodyPivot.remove_child(l_hand)
    weapon.u_hand_pivot.add_child(u_hand) 
    weapon.l_hand_pivot.add_child(l_hand)
    u_hand.position = Vector2()
    l_hand.position = Vector2()
    u_hand.z_index = 0
    l_hand.z_index = 0

func unequip_weapon(wep_path):
    pass

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
    var co = move_and_collide(velocity * delta)
    if co:
        emit_signal("unit_collided", co)
