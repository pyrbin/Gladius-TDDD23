# Interface class for game units
extends KinematicBody2D

#signals
signal unit_collided

# enums
enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}

# exports
export (String) var unit_name = ""
export (bool) var use_hands = false
export (bool) var use_holster = true
export (float) var reach = 40

export (Array, int) var equipped_items = []
export (Array, int) var container_slots_types = []

# visuals
onready var body = $Visuals/Pivot/Container/Body
onready var sprite_player = $SpritePlayer
onready var weapon_pivot = $Visuals/Pivot/WeaponPivot
onready var shadow = $Visuals/Shadow
onready var u_hand = $Visuals/Pivot/U_Hand_Pivot/U_Hand
onready var l_hand = $Visuals/Pivot/L_Hand_Pivot/L_Hand
onready var legs = $Visuals/Pivot/Container/Legs
onready var chest = $Visuals/Pivot/Container/Chest
onready var holster = $Visuals/Pivot/Container/Chest/Holster
onready var helm = $Visuals/Pivot/Container/Helm

# data 
onready var holster_timer = $HolsterTimer
onready var health = $Health

# constans
const WEAPON_FOLDER_PATH = "res://scenes/weapons/"
const Equippable = preload("res://data/equippable.gd")

# member variables
var look_state = TOP_RIGHT
var look_position = Vector2(0,0)
var velocity = Vector2(0,0)
var dead = false
var weapon = null
var weapon_sprite = null
var equipment = null

func _ready():

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

func equip_weapon(wep_data):
    weapon_pivot.add_child(load(wep_data.model).instance())
    var wep = weapon_pivot.get_child(0)
    wep.load_weapon(wep_data)
    wep.holder = self
    wep.set_reach(reach)
    weapon = wep
    weapon_sprite = weapon.wep_sprite
    if use_hands:
        _hands_on_weapon(true)
    if use_holster:
        holster_timer.start()

func unequip_weapon():
    if not weapon: return
    unholster_weapon()
    _hands_on_weapon(false)
    weapon.hide()
    weapon_pivot.remove_child(weapon)
    weapon = null
    pass

func holster_weapon():
    if not weapon:
        return
    _hands_on_weapon(false)
    weapon.set_holstered(true)
    holster.set_texture(load(weapon.data.sprite))
    holster.show() 
    holster.set_offset(weapon.holster_offset)

func unholster_weapon():
    if not weapon or not weapon.is_holstered():
        return
    _hands_on_weapon(true)
    weapon.set_holstered(false)
    holster.hide()

func left_attack_weapon():
    if not weapon: return
    if weapon.is_holstered():
        unholster_weapon();
    weapon.attack(0)
    if use_holster:
        holster_timer.start()

func right_attack_weapon():
    if not weapon: return
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
    
    if weapon and (weapon.is_idle() || weapon.is_holstered()):
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

func _flip_armor(b):
    legs.set_flip_h(b)
    chest.set_flip_h(b)
    helm.set_flip_h(b)
    if weapon && weapon.is_holstered():
        var mod =  -60 if b else -50
        holster.rotation = mod

func _hands_on_weapon(b):
    if b:
        $Visuals/Pivot/U_Hand_Pivot.remove_child(u_hand)
        $Visuals/Pivot/L_Hand_Pivot.remove_child(l_hand)
        weapon.u_hand_pivot.add_child(u_hand) 
        weapon.l_hand_pivot.add_child(l_hand)
    else:
        weapon.u_hand_pivot.remove_child(u_hand) 
        weapon.l_hand_pivot.remove_child(l_hand)
        $Visuals/Pivot/U_Hand_Pivot.add_child(u_hand)
        $Visuals/Pivot/L_Hand_Pivot.add_child(l_hand)
    u_hand.position = Vector2()
    l_hand.position = Vector2()
    u_hand.z_index = 0
    l_hand.z_index = 0

func set_dead(value):
    dead = value
    set_process_input(not value)
    set_physics_process(not value)

func _on_collision(body):
    pass

func _update_equipment_slot(slot):
    var equip_id = equipment.get(slot)
    var type = equipment.get_type(slot)
    var equippable = gb_ItemDatabase.get_item(equip_id)
    var texture = null
    var armor_sprite = null

    # TODO: fix the if clauses, do i even know what DRY means?
    if type == Equippable.SLOT.WEAPON: 
        if weapon:
            unequip_weapon()
            return
        elif equippable:
            equip_weapon(equippable)
        return

    if type == Equippable.SLOT.WEAPON: return
    if type == -1: return

    match type:
        Equippable.SLOT.HELM: armor_sprite = helm
        Equippable.SLOT.CHEST: armor_sprite = chest
        Equippable.SLOT.LEGS: armor_sprite = legs
    
    if equippable != null: 
        texture = equippable.sprite

    armor_sprite.set_texture(load(texture) if texture else null)

func _on_equipment_change(slot):
    _update_equipment_slot(slot)

func _equip_equipments():
    for i in equipment.size():
        _update_equipment_slot(i)

func _physics_process(delta):
    _set_look_state(get_aim_position())
    if holster_timer.is_stopped() && weapon && weapon.is_ready() && use_holster:
        holster_weapon()
    var collision = move_and_collide(velocity * delta)
    if collision:
        _on_collision(collision)
        emit_signal("unit_collided", collision)
    velocity = Vector2()
