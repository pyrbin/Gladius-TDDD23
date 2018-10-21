extends "res://scenes/common/obstacle.gd"

export (int) var weapon_id = 0
export (int, FLAGS, "Neutral", "Player", "Enemy", "Bosses") var weapon_collision = 0
export (int, FLAGS, "North", "East", "South", "West") var aim_direction = 0
export (float) var reach = 40
export (AudioStream) var sfx_bashed

onready var weapon_pivot = $Pivot/Weapon_Pivot
onready var u_hand = $Pivot/U_Hand_Pivot/U_Hand
onready var l_hand = $Pivot/L_Hand_Pivot/L_Hand
onready var weapon = null
onready var weapon_sprite = null

var velocity_mod = Vector2()
var velocity = Vector2()

func _ready():
    if weapon_id != 0:
        equip_weapon(gb_ItemDatabase.get_item(weapon_id))

func _process(d):
    if weapon and (weapon.is_idle() || weapon.is_holstered()):
        weapon_pivot.look_at(get_aim_position())
    if weapon.is_ready():
        weapon.attack()

func _physics_process(delta):
    if velocity_mod:
        velocity = velocity_mod
    move_and_collide(velocity * delta)
    velocity = Vector2()

func get_aim_position():
    var offset = Vector2()

    if utils.is_bit(0, aim_direction):
        offset = Vector2(0, -150)
    elif utils.is_bit(1, aim_direction):
        offset = Vector2(150, 0)
    elif utils.is_bit(2, aim_direction):
        offset = Vector2(0, 150)
    elif utils.is_bit(3, aim_direction):
        offset = Vector2(-150, 0)

    return global_position + offset

func equip_weapon(wep_data):
    weapon_pivot.add_child(load(wep_data.model).instance())
    var wep = weapon_pivot.get_child(0)
    wep.load_weapon(wep_data, self, weapon_collision)
    wep.set_reach(reach)
    weapon = wep
    weapon.weapon_attack_speed += 300
    weapon_sprite = weapon.wep_sprite
    _hands_on_weapon(true)
    
func bashed(basher, direction):
    if basher == utils.get_player():
        utils.get_player().camera.shake(0.30, 50, 3)
    if !weapon.is_idle():
        charge(-800, 0.15, direction)
        weapon.interuppt()
        utils.play_sound(sfx_bashed, $AudioPlayer)
        var action = gb_CombatText.HitInfo.ACTION.BLOCK
        var type = gb_CombatText.HitInfo.TYPE.NORMAL
        var hit_info = gb_CombatText.HitInfo.new(0, basher, self, type, action)
        gb_CombatText.popup(hit_info, global_position)

func charge(force, speed, direction):
    velocity_mod = direction * force
    $Tween.interpolate_property(self, "velocity_mod", velocity_mod, Vector2(), speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    $Tween.start()

func _on_Tween_tween_completed(obj, path):
    set_dead(true)

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

func set_dead(value):
    .set_dead(value)
    $CollisionShape2D.disabled = false;
