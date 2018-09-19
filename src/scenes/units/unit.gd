# Interface class for game units
extends KinematicBody2D

#signals
signal unit_collided
signal took_damage(amount, actor)
signal attacking

# enums
enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}

# exports
export (bool) var use_hands = false
export (bool) var use_holster = true
export (float) var reach = 40

export (Array, int) var equipment_container_slots = [3]
export (Array, int) var equipped_items = [3]
export (Array, int) var equipped_weapons = [2]

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
onready var stats = $Stats

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
var action_equipment = null

#   Setup functions
#   =========================
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

    var item_container = load("res://scripts/item_container/item_container.gd")
    equipment = item_container.new()
    action_equipment = item_container.new()
    equipment.init(equipment_container_slots, equipped_items)
    action_equipment.init([3, 4], equipped_weapons)
    equipment.connect("value_changed", self, "_on_equipment_change")
    action_equipment.connect("value_changed", self, "_on_action_equipment_change")
    _equip_equipments()
    _setup()
    
func _setup():
    pass
#   Unit ingame actions
#   =========================
func use_consumable():
    var consumable = action_equipment.get(1)
    if !consumable: return
    for attr in consumable.attributes:
        stats.mod_modifier(attr, consumable.attributes[attr], "VALUE")

func left_attack_weapon():
    if not weapon: return
    if weapon.is_holstered():
        unholster_weapon();
    if weapon.attack(0):
        emit_signal("attacking")
    if use_holster:
        holster_timer.start()

func right_attack_weapon():
    stats.set_modifier(stats.ATTR.HEALTH, 0, stats.MODIFIER.PERCENT)

func take_damage(amount, actor, mod="VALUE"):
    stats.mod_modifier("HEALTH", -amount, mod)
    emit_signal("took_damage", amount, actor)

#   Sprite manipulation
#   =========================
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

#   Equipment functions
#   =========================
func add_item(item_id):
    var item = gb_ItemDatabase.get_item(item_id)
    if item == null: return
    if item.slot == Equippable.SLOT.WEAPON || item.slot == Equippable.SLOT.SPECIAL:
        var slot = action_equipment.get_equip_slot(item.slot)
        drop_item(slot, action_equipment)
        action_equipment.set(slot, item_id)
    else:
        var slot = equipment.get_equip_slot(item.slot)
        drop_item(slot, equipment)
        equipment.set(slot, item_id)

# TODO: this function is not DRY, repeated in "scenes/interactable/lootable/lootable.gd"
func drop_item(index, item_container, offset = Vector2(0, -10)):
    if item_container != equipment and item_container != action_equipment: return
    var item = item_container.get(index)
    item_container.delete(index)
    if item == null: return
    var instance = load("res://scenes/interactable/item/Item.tscn").instance()
    get_tree().get_nodes_in_group("Root_Items")[0].add_child(instance)
    instance.set_item(item)
    instance.position = global_position + offset

func _update_equipment_slot(slot, use_action_equipment):
    var equip_id = equipment.get(slot) if not use_action_equipment else action_equipment.get(slot)
    var type = equipment.get_type(slot) if not use_action_equipment else action_equipment.get_type(slot)
    var equippable = gb_ItemDatabase.get_item(equip_id)
    var texture = null
    var armor_sprite = null

    if type == Equippable.SLOT.WEAPON: 
        if weapon:
            unequip_weapon()
        if equippable:
            equip_weapon(equippable)
        return
    
    if type == Equippable.SLOT.WEAPON || type == Equippable.SLOT.SPECIAL: return
    if use_action_equipment: return
    if type == -1: return

    match type:
        Equippable.SLOT.HELM: armor_sprite = helm
        Equippable.SLOT.CHEST: armor_sprite = chest
        Equippable.SLOT.LEGS: armor_sprite = legs
    
    if equippable != null: 
        texture = equippable.sprite

    armor_sprite.set_texture(load(texture) if texture else null)

func _on_equipment_change(slot):
    _update_equipment_slot(slot, false)

func _on_action_equipment_change(slot):
    _update_equipment_slot(slot, true)

func _equip_equipments():
    for i in equipment.size():
        _update_equipment_slot(i, false)
    for i in action_equipment.size():
        _update_equipment_slot(i, true)



#   Process loop
#   =========================
func _physics_process(delta):
    if !dead:
        _set_look_state(get_aim_position())
        if holster_timer.is_stopped() && weapon && weapon.is_ready() && use_holster:
            holster_weapon()
    _handle_collision(delta)  

func _handle_collision(delta):
    var collision = move_and_collide(velocity * delta)
    if collision:
        _on_collision(collision)
        emit_signal("unit_collided", collision)
    velocity = Vector2()

func set_dead(value):
    dead = value

func get_aim_position():
    pass

func get_movement_direction():
    pass

func _on_collision(body):
    pass

func _on_Stats_on_health_zero():
	set_dead(true)

func _on_Stats_on_revive():
	set_dead(false)