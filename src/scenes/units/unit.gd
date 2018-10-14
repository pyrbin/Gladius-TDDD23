# Interface class for game units
extends KinematicBody2D

#signals
signal unit_collided
signal took_damage(amount, actor, soft)
signal staggered(actor)
signal attacking
signal used_special(special)
signal combo(point)
signal lost_combo(point)
signal weapon_equipped(weapon)

const Equippable = preload("res://data/equippable.gd")

# enums
enum LOOK_STATE {TOP_RIGHT, TOP_LEFT, BOTTOM_RIGHT, BOTTOM_LEFT}

# exports
export (bool) var use_hands = false
export (bool) var use_holster = true
export (float) var reach = 40
export (float) var stagger_time = 4

export (Array, int, "DEFAULT", "HELM", "CHEST", "LEGS", "WEAPON", "SPECIAL") var equipment_container_slots = []
export (Array, int) var equipped_items = []
export (Array, int) var equipped_weapons = []
export (int, FLAGS, "Neutral", "Player", "Enemy", "Bosses") var weapon_collision 
export (AudioStream) var sfx_bash
export (AudioStream) var sfx_bashed
export (AudioStream) var sfx_hurt

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
onready var hitbox = $Hitbox/CollisionShape2D

# data 
onready var status = $Status
onready var stats = $Stats
onready var holster_timer = $HolsterTimer
onready var bash_timer = $BashTimer

# constans
const WEAPON_FOLDER_PATH = "res://scenes/weapons/"
const BLOCK_TIME = 1000

# combat vars
var iframe = false
var bashing = false
var dead = false
var invunerable = false

# member variables
var look_state = TOP_RIGHT
var look_position = Vector2(0,0)
var velocity = Vector2(0,0)
var velocity_mod = Vector2()

# weapon
var weapon = null
var weapon_sprite = null
var skin_color = null

# equipment
var equipment = null
var action_equipment = null


#   Setup functions
#   =========================
func _ready():
    # Hand management
    if use_hands:
        u_hand.show()
        l_hand.show()
    else:
        u_hand.hide()
        l_hand.hide()
    
    # Skin tones
    randomize()
    var skin_tones = [Color("#ffb695"), Color("#784734"), Color("#ff9a6d"), Color("#965738")]
    skin_color = skin_tones[randi()%len(skin_tones)]
    body.modulate = skin_color
    u_hand.modulate = skin_color
    l_hand.modulate = skin_color
    sprite_player.get_animation("stagger").track_set_key_value(0, 1, skin_color)
    sprite_player.get_animation("blocked").track_set_key_value(0, 1, skin_color)


    # Equipment
    var item_container = load("res://scripts/item_container/item_container.gd")
    equipment = item_container.new()
    action_equipment = item_container.new()
    equipment.init(equipment_container_slots, equipped_items)
    action_equipment.init([Equippable.SLOT.WEAPON, Equippable.SLOT.SPECIAL], equipped_weapons)

    # Connect signals
    equipment.connect("value_changed", self, "_on_equipment_change")
    action_equipment.connect("value_changed", self, "_on_action_equipment_change")
    _equip_equipments()
    _setup()
    
func _setup():
    pass
    
#   Unit ingame actions 
#   =========================
func use_consumable():
    var slot = action_equipment.get_equip_slot(Equippable.SLOT.SPECIAL)
    var id = action_equipment.get(slot)
    var special = gb_ItemDatabase.get_item(id)
    if not special || not $SpecialHandler.cooldown.is_stopped(): return
    $SpecialHandler.use(special)
    emit_signal("used_special", special)
    
func attack_weapon():
    if not weapon: return
    if weapon.is_holstered():
        unholster_weapon();
    if weapon.attack():
        if weapon.data.weapon_type != 2 && name == "Player":
            charge(400, 0.1)
        if weapon.data.weapon_type == 2:
            charge(200, 0.1, -get_aim_direction())
        emit_signal("attacking")
    if use_holster:
        holster_timer.start()

func charge(force, speed, direction = get_aim_direction()):
    velocity_mod = direction * force
    $Tween.interpolate_property(self, "velocity_mod", velocity_mod, Vector2(), speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()

func bash():
    if bashing || not bash_timer.is_stopped(): return
    utils.play_sound(sfx_bash, $VoicePlayer)
    charge(700, 0.15)
    iframe = true
    bashing = true
    sprite_player.play("iframe")
    for unit in $Hitbox.get_overlapping_bodies():
        print(unit)
        if unit != self:
            _on_Hitbox_body_entered(unit)
            return
    yield(utils.timer(0.2), 'timeout')
    _reset_bash()
    
func bashed(basher, direction):
    if basher == utils.get_player():
        utils.get_player().camera.shake(0.30, 50, 3)
    if !weapon.is_idle() && !weapon.is_holstered():
        charge(-800, 0.15, direction)
        weapon.interuppt()
        var action = gb_CombatText.HitInfo.ACTION.BLOCK
        var type = gb_CombatText.HitInfo.TYPE.NORMAL
        var hit_info = gb_CombatText.HitInfo.new(0, basher, self, type, action)
        gb_CombatText.popup(hit_info, global_position)
        utils.play_sound(sfx_bashed, $VoicePlayer)
    else:
        utils.play_sound(sfx_hurt, $VoicePlayer)
    charge(-400, 0.15, direction)
    stagger(basher)
    
func is_in_bash(target):
    return target.global_position.distance_to(global_position) < 100

func _reset_bash():
    $Tween.stop_all()
    iframe = false
    bashing = false
    velocity_mod = Vector2()
    sprite_player.stop()
    reset_modulate()
    $Visuals/Pivot.material = null
    bash_timer.start()

func _on_Hitbox_body_entered(body):
    if bashing && body.has_method("bashed") && not body.has_iframe():
        body.bashed(self, -get_aim_direction())
        _reset_bash()

func stagger(actor):
    #sprite_player.play("stagger")
    emit_signal("staggered", actor)

func soft_damage(amount, actor, crit=false):
    damage(amount, actor, true, true, crit)
    
func damage(amount, actor, unblockable=false, soft_attack=false, crit=false):
    if dead || invunerable: return false
    if iframe && not soft_attack: return false
    var hit_info = null
    var action = null
    var type = null
    status.damage(amount)
    emit_signal("took_damage", amount, actor, soft_attack)
    action = gb_CombatText.HitInfo.ACTION.HEAL if amount <= 0 else gb_CombatText.HitInfo.ACTION.DAMAGE
    type = gb_CombatText.HitInfo.TYPE.NORMAL if not crit else gb_CombatText.HitInfo.TYPE.CRIT
    hit_info = gb_CombatText.HitInfo.new(amount, actor, self, type, action)
    gb_CombatText.popup(hit_info, global_position)
    if amount >= 0:
        utils.play_sound(sfx_hurt, $VoicePlayer)
    return true

func fatigue(amount, actor, unblockable=false):
    if dead: return
    status.fatigue(amount)

func add_to_body(child):
    $Visuals/Pivot/Container.add_child(child)
    
func set_velocity(value):
    velocity = value

func has_iframe():
    return iframe

func get_range():
    return 0

func equip_armor(array):
    for d in range(0, len(array)):
        equipment.set(d, array[d])

func equip_wep(array):
    for d in range(0, len(array)):
        action_equipment.set(d, array[d])

func default_modulate():
    body.modulate = Color(1,1,1,1)
    if u_hand && l_hand:
        u_hand.modulate = Color(1,1,1,1)
        l_hand.modulate = Color(1,1,1,1)

func reset_modulate():
    get_node("Visuals/Pivot/Container").modulate = Color(1,1,1,1)
    get_node("Visuals/Pivot/WeaponPivot").modulate = Color(1,1,1,1)
    get_node("Visuals/Pivot/L_Hand_Pivot").modulate = Color(1,1,1,1)
    get_node("Visuals/Pivot/U_Hand_Pivot").modulate = Color(1,1,1,1)
    body.modulate = skin_color
    if u_hand && l_hand:
        u_hand.modulate = skin_color
        l_hand.modulate = skin_color
    $Visuals/Pivot.material = null
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
            _flip_armor(true)
        TOP_RIGHT:
            _flip_armor(false)
        BOTTOM_LEFT:
            _flip_armor(true)
        BOTTOM_RIGHT:
            _flip_armor(false)

func _flip_armor(b):
    legs.set_flip_h(b)
    chest.set_flip_h(b)
    helm.set_flip_h(b)
    body.set_flip_h(b)
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
    wep.load_weapon(wep_data, self, weapon_collision)
    wep.set_reach(reach)
    weapon = wep
    weapon_sprite = weapon.wep_sprite
    if use_hands:
        _hands_on_weapon(true)
    if use_holster:
        holster_timer.start()
    weapon.connect("combo", self, "_on_wep_combo")
    weapon.connect("lost_combo", self, "_on_wep_lost_combo")
    emit_signal("weapon_equipped", weapon)

func _on_wep_combo(point):
    emit_signal("combo", point)

func _on_wep_lost_combo(point):
    emit_signal("lost_combo", point)

func get_weapon_node():
    if not weapon_pivot: return null
    return weapon_pivot.get_child(0)

func unequip_weapon():
    if not weapon: return
    unholster_weapon()
    _hands_on_weapon(false)
    weapon.hide()
    weapon_pivot.remove_child(weapon)
    _on_wep_lost_combo(0)
    weapon.disconnect("combo", self, "_on_wep_combo")
    weapon.disconnect("lost_combo", self, "_on_wep_lost_combo")
    weapon = null

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

    if type == Equippable.SLOT.WEAPON || type == Equippable.SLOT.SPECIAL: return
    if use_action_equipment: return
    if type == 0: return

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
    if velocity_mod:
        velocity = velocity_mod
    var collision = move_and_collide(velocity * delta)
    if collision:
        _on_collision(collision)
        emit_signal("unit_collided", collision)
    velocity = Vector2()

func set_dead(value):
    dead = value
    $Hitbox/CollisionShape2D.disabled = dead
    stats.clear_effects()

func has_ranged_wep():
    if not weapon: return false
    return weapon.data.weapon_type == 2

func get_aim_position():
    return Vector2()


func get_aim_direction():
    return -(global_position-get_aim_position()).normalized()

func get_movement_direction():
    return Vector2()

func _on_collision(body):
    pass

func _on_Status_on_health_zero():
    set_dead(true)

func _on_Status_on_revive():
    set_dead(false)

func _on_SpritePlayer_animation_finished(name):
    reset_modulate()