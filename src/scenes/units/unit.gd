# Interface class for game units
extends KinematicBody2D

signal unit_collided
enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}

export (String) var unit_name = ""
export (String) var weapon_path = "swing_weapon/shortsword/Shortsword.tscn"
export (bool) var use_hands = false
export (float) var reach = 40

onready var shadow = $Shadow
onready var u_hand = $Pivot/U_Hand_Pivot/U_Hand
onready var l_hand = $Pivot/L_Hand_Pivot/L_Hand
onready var body = $Pivot/Container/Body
onready var sprite_player = $SpritePlayer
onready var weapon_pivot = $Pivot/WeaponPivot
onready var health = $Health

const UNIT_DRAW_LAYER = 2
const SHADOW_DRAW_LAYER = 1
const WEAPON_DRAW_LAYER = 6
const WEAPON_DRAW_LAYER_TOP_OFFSET = 0
const WEAPON_FOLDER_PATH = "res://scenes/weapons/"

var look_state = TOP_RIGHT
var look_position = Vector2(0,0)
var velocity = Vector2(0,0)
var dead = false
var weapon

func _ready():
    body.z_index = UNIT_DRAW_LAYER
    shadow.z_index = SHADOW_DRAW_LAYER

    if use_hands:
        u_hand.show()
        l_hand.show()
    else:
        u_hand.hide()
        l_hand.hide()

    equip_weapon(weapon_path)

func equip_weapon(wep_path):
    weapon_pivot.add_child(load(WEAPON_FOLDER_PATH + "swing_weapon/shortsword/Shortsword.tscn").instance())
    weapon = weapon_pivot.get_child(0)
    weapon.holder = self
    weapon.set_reach(reach)
    print("Weapon Equipped: "+weapon.data.identifier)

    if use_hands:
        reparent_hands()

func unequip_weapon(wep_path):
    pass

func left_attack_weapon():
    weapon.attack(0);

func right_attack_weapon():
    weapon.attack(1);

func get_aim_position():
    pass

func get_movement_direction():
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
            sprite_player.play("Bottom_Left")
            _flip_armor(true)
        TOP_RIGHT:
            sprite_player.play("Bottom_Right")
            _flip_armor(false)
        BOTTOM_LEFT:
            sprite_player.play("Bottom_Left")
            _flip_armor(true)
        BOTTOM_RIGHT:
            sprite_player.play("Bottom_Right")
            _flip_armor(false)

    _determine_wep_z_index()
func _flip_armor(b):
    $Pivot/Container/Legs.set_flip_h(b)
    $Pivot/Container/Chest.set_flip_h(b)
    $Pivot/Container/Helm.set_flip_h(b)
func reparent_hands():
    $Pivot/U_Hand_Pivot.remove_child(u_hand)
    $Pivot/L_Hand_Pivot.remove_child(l_hand)
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
