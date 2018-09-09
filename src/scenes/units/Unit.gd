# Interface class for game units
extends KinematicBody2D

signal unit_collided
enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}

export (String) var unit_name = ""
export (String) var weapon_path = "swing_weapon/shortsword/Shortsword.tscn"

onready var shadow = $Shadow
onready var u_hand = $BodyPivot/U_Hand
onready var l_hand = $BodyPivot/L_Hand
onready var body = $BodyPivot/Body
onready var sprite_player = $SpritePlayer
onready var weapon_pivot = $BodyPivot/WeaponPivot
onready var health = $Health

const UNIT_DRAW_LAYER = 6
const SHADOW_DRAW_LAYER = 1
const WEAPON_DRAW_LAYER = 7
const WEAPON_DRAW_LAYER_TOP_OFFSET = -5
const WEAPON_FOLDER_PATH = "res://scenes/weapons/"

var look_state = TOP_RIGHT
var look_position = Vector2(0,0)
var velocity = Vector2(0,0)
var dead = false
var weapon

func _ready():
    body.z_index = UNIT_DRAW_LAYER
    shadow.z_index = SHADOW_DRAW_LAYER
    equip_weapon(weapon_path)

func equip_weapon(wep_path):
    weapon_pivot.add_child(load(WEAPON_FOLDER_PATH + wep_path).instance())
    weapon = weapon_pivot.get_child(0)
    weapon.holder = self
    print("Weapon Equipped: "+weapon.weapon_name)
    reparent_hands()

func unequip_weapon(wep_path):
    pass

func get_movement_direction():
    pass

func left_attack_weapon():
    weapon.attack();

func get_aim_position():
    pass

func _set_look_state(look_position):
    if dead:
        return

    if look_position.x > body.global_position.x:
        look_state = BOTTOM_RIGHT if look_position.y > body.global_position.y else TOP_RIGHT
    else:
        look_state = BOTTOM_LEFT if look_position.y > body.global_position.y else TOP_LEFT
    
    if weapon.is_idle():
        weapon_pivot.look_at(get_aim_position())

    match look_state:
        TOP_LEFT:
            sprite_player.play("Top_Left")
        TOP_RIGHT:
            sprite_player.play("Top_Right")
        BOTTOM_LEFT:
            sprite_player.play("Bottom_Left")
        BOTTOM_RIGHT:
            sprite_player.play("Bottom_Right")
    _determine_wep_z_index()

func reparent_hands():
    $BodyPivot.remove_child(u_hand)
    $BodyPivot.remove_child(l_hand)
    weapon.u_hand_pivot.add_child(u_hand) 
    weapon.l_hand_pivot.add_child(l_hand)
    u_hand.position = Vector2()
    l_hand.position = Vector2()
    u_hand.z_index = 0
    l_hand.z_index = 0
func _determine_wep_z_index():
    if look_state == TOP_LEFT or look_state == TOP_RIGHT:
        weapon_pivot.z_index = WEAPON_DRAW_LAYER + WEAPON_DRAW_LAYER_TOP_OFFSET
    else:
        weapon_pivot.z_index = WEAPON_DRAW_LAYER

func set_dead(value):
    dead = value
    set_process_input(not value)
    set_physics_process(not value)

func _physics_process(delta):
    _set_look_state(get_aim_position())
    var collision = move_and_collide(velocity * delta)
    if collision:
        emit_signal("unit_collided", collision)
    velocity = Vector2()
