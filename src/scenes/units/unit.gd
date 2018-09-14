# Interface class for game units
extends KinematicBody2D

#signals
signal unit_collided

# enums
enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}

# exports
export (String) var unit_name = ""
export (String) var weapon_path = "swing_weapon/shortsword/Shortsword.tscn"
export (bool) var use_hands = false
export (bool) var use_holster = true
export (float) var reach = 40

export (Array, int) var equipped_items = []
export (Array, int) var container_slots_types = []

# visuals
onready var body = $Pivot/Container/Body
onready var sprite_player = $SpritePlayer
onready var weapon_pivot = $Pivot/WeaponPivot
onready var shadow = $Shadow
onready var u_hand = $Pivot/U_Hand_Pivot/U_Hand
onready var l_hand = $Pivot/L_Hand_Pivot/L_Hand
onready var legs = $Pivot/Container/Legs
onready var chest = $Pivot/Container/Chest
onready var helm = $Pivot/Container/Helm

# data 
onready var holster_timer = $HolsterTimer
onready var health = $Health

# constans
const UNIT_DRAW_LAYER = 1
const SHADOW_DRAW_LAYER = 1
const WEAPON_HOLSTERED_DRAW_LAYER = -4
const WEAPON_DRAW_LAYER = 6
const WEAPON_DRAW_LAYER_TOP_OFFSET = 0
const WEAPON_FOLDER_PATH = "res://scenes/weapons/"
const WEAPON_HOLSTER_ROT = -90
const Equippable = preload("../items/equippable.gd")

# member variables
var look_state = TOP_RIGHT
var look_position = Vector2(0,0)
var velocity = Vector2(0,0)
var dead = false
var weapon
var equipment

func _ready():
    body.z_index = UNIT_DRAW_LAYER
    shadow.z_index = SHADOW_DRAW_LAYER

    if use_hands:
        u_hand.show()
        l_hand.show()
    else:
        u_hand.hide()
        l_hand.hide()
    randomize()
    var skin_tones = [Color("#8d5524"), Color("#c68642"), Color("#f1c27d"), Color("#f1c27d"), Color("#ffdbac")]
    var skin_color = skin_tones[randi()%skin_tones.size()]
    body.modulate = skin_color
    u_hand.modulate = skin_color
    l_hand.modulate = skin_color
    equipment = load("res://scenes/item_container/item_container.gd").new()
    equipment.init(container_slots_types, equipped_items)
    equipment.connect("value_changed", self, "_on_equipment_change")
    _equip_equipments();
    equip_weapon(weapon_path)

func equip_weapon(wep_path):
    weapon_pivot.add_child(load(WEAPON_FOLDER_PATH + "swing_weapon/shortsword/Shortsword.tscn").instance())
    weapon = weapon_pivot.get_child(0)
    weapon.holder = self
    weapon.set_reach(reach)
    if use_hands:
        _hands_on_weapon(true)
    if use_holster:
        holster_timer.start()

func unequip_weapon(wep_path):
    pass

func holster_weapon():
    if not weapon:
        return
    weapon.set_holstered(true)
    weapon_pivot.rotation = 0
    weapon_pivot.rotation = WEAPON_HOLSTER_ROT
    weapon.z_index = WEAPON_HOLSTERED_DRAW_LAYER
    _hands_on_weapon(false)

func unholster_weapon():
    if not weapon or not weapon.is_holstered():
        return
    weapon.set_holstered(false)
    weapon.set_reach(reach)
    weapon.z_index = 0
    if use_hands:
        _hands_on_weapon(true)

func left_attack_weapon():
    if weapon.is_holstered():
        unholster_weapon();
    weapon.attack(0)
    if use_holster:
        holster_timer.start()

func right_attack_weapon():
    if weapon.is_holstered():
        unholster_weapon();
    weapon.attack(1)
    if use_holster:
        holster_timer.start()

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
    legs.set_flip_h(b)
    chest.set_flip_h(b)
    helm.set_flip_h(b)
    if weapon.is_holstered():
        var mod = -1 if b else 1
        weapon_pivot.rotation = mod * WEAPON_HOLSTER_ROT

func _hands_on_weapon(b):
    if b:
        $Pivot/U_Hand_Pivot.remove_child(u_hand)
        $Pivot/L_Hand_Pivot.remove_child(l_hand)
        weapon.u_hand_pivot.add_child(u_hand) 
        weapon.l_hand_pivot.add_child(l_hand)
    else:
        weapon.u_hand_pivot.remove_child(u_hand) 
        weapon.l_hand_pivot.remove_child(l_hand)
        $Pivot/U_Hand_Pivot.add_child(u_hand)
        $Pivot/L_Hand_Pivot.add_child(l_hand)
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

func _on_collision(body):
    pass

func _visualize_equipment_slot(slot):
    var armor_id = equipment.get(slot)
    var type = equipment.get_type(slot)
    var armor = gb_ItemDatabase.get_item(armor_id)
    var texture = null
    var armor_sprite = null

    if type == Equippable.SLOT.WEAPON: return
    if type == -1: return

    match type:
        Equippable.SLOT.HELM: armor_sprite = helm
        Equippable.SLOT.CHEST: armor_sprite = chest
        Equippable.SLOT.LEGS: armor_sprite = legs
    
    if armor != null: 
        texture = armor.sprite

    armor_sprite.set_texture(load(texture) if texture else null)
    armor_sprite.set_visible(texture != null)

func _on_equipment_change(slot):
    _visualize_equipment_slot(slot)

func _equip_equipments():
    for i in equipment.size():
        _visualize_equipment_slot(i)

func _physics_process(delta):
    _set_look_state(get_aim_position())
    if holster_timer.is_stopped() && not weapon.is_holstered() && use_holster:
        holster_weapon()
    var collision = move_and_collide(velocity * delta)
    if collision:
        _on_collision(collision)
        emit_signal("unit_collided", collision)
    velocity = Vector2()
