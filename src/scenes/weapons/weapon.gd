extends Node2D

export (Vector2) var holster_offset = Vector2(52,0)
export (float) var hit_range = 50

enum ATTACK_STATE { IDLE, ATTACKING, HOLSTERED }

const WeaponData = preload("res://data/weapon_data.gd")
const HITABLE_GROUP_NAME = "Hitable"
const KNOCKBACK_FORCE = 250
const COMBO_MAX_POINTS = 3
const ATK_FASTEST = 0.2

onready var wep_sprite = $Pivot/Area2D/Sprite
onready var anim_player = $AnimationPlayer
onready var u_hand_pivot = $Pivot/Area2D/Sprite/U_Hand_Pivot
onready var l_hand_pivot = $Pivot/Area2D/Sprite/L_Hand_Pivot
onready var knockback_tween = $KnockbackTween
onready var cooldown_timer = $Timer
onready var hitbox = $Pivot/Area2D/Hitbox

signal combo(point)
signal lost_combo(point)

var data = null
var holder = null

var _combo_sequence = 0
var _is_loaded = false
var _attack_state = IDLE
var _knockback_force = Vector2()
var _knockback_mod = 1
var _knockback_air_mod = 1
var _interuppted = false
var _target = null
var _current_hit_targets = []

func _ready():
    $Pivot/Area2D.connect("area_entered", self, "_on_body_entered_root")
    anim_player.connect("animation_finished", self, "_on_animation_finished")
    cooldown_timer.connect("timeout", self, "_on_cooldown_finished")
    hitbox.disabled = true

func _physics_process(d):
    if knockback_tween.is_active() && _target:
        _target.velocity = _knockback_force

func see_target(target):
    return target.global_position.distance_to(global_position) < hit_range

func set_holstered(b):
    hide() if b else show()
    _attack_state = HOLSTERED if b else IDLE

func load_weapon(p_weapon_data, p_holder, p_collision_mask = null):
    data = p_weapon_data
    holder = p_holder
    $Pivot/Area2D.collision_mask = p_collision_mask
    wep_sprite.set_texture(load(data.sprite))
    cooldown_timer.wait_time = data.cooldown
    _is_loaded = true
    _setup()

func _setup():
    pass
    
func set_reach(offset):
    $Pivot/Area2D.position = Vector2(offset, $Pivot/Area2D.position.y)

func is_ready():
    return _attack_state == IDLE && cooldown_timer.is_stopped() && _is_loaded

func is_idle():
    return _attack_state == IDLE && _is_loaded

func is_holstered():
    return _attack_state == HOLSTERED && _is_loaded

func _action_attack():
    pass

func _action_ult_attack():
    pass

func attack():
    var atk_bonus = clamp(data.attack_speed-holder.stats.get_stat(STAT.ATK_SPEED), ATK_FASTEST, 99999)/1000.0
    anim_player.playback_speed = 1/atk_bonus
    _interuppted = false
    if not _is_loaded: return false
    if not is_ready(): return false
    hitbox.disabled = false
    _attack_state = ATTACKING
    if _combo_sequence == COMBO_MAX_POINTS:
        _action_ult_attack()
    else:
        _action_attack()
    cooldown_timer.start()
    return true

func interuppt():
    reset_combo()
    _interuppted = true

func is_hitable(body):
    return body != null \
    && body != holder \
    && body.is_in_group(HITABLE_GROUP_NAME) \
    && !_current_hit_targets.has(body) \
    && body.has_method("damage") \
    && !body.has_iframe() \
    && !_interuppted

func _on_body_entered_root(area):
    if _attack_state != ATTACKING: return
    var body = area.owner
    if not is_hitable(body): return
    _current_hit_targets.append(body)
    _on_body_entered(body)

func _on_body_entered(body, count_for_combo=true):
    _target = body
    var tar = _target.damage(data.damage+holder.stats.get_stat(STAT.POWER), self)
    if holder == utils.get_player():
        utils.freeze_time(0.028)
        if data.damage > 0:
            holder.camera.shake(0.30, 50, 3)
    if _target != utils.get_player():
        _knockback()
    if count_for_combo:
        if tar && _combo_sequence != COMBO_MAX_POINTS:
            if len(_current_hit_targets) <= 1:
                $ComboTimer.start()
                _combo_sequence+=1
                emit_signal("combo", _combo_sequence)
        elif len(_current_hit_targets) <= 1:
            print(len(_current_hit_targets))
            reset_combo()

func reset_combo():
    $ComboTimer.stop()
    emit_signal("lost_combo", _combo_sequence)
    _combo_sequence=0

func _on_ComboTimer_timeout():
    if _combo_sequence > 0:
        reset_combo()

func _knockback():
    var angle = holder.global_position.angle_to_point(holder.get_aim_position())
    var dir = Vector2(-cos(angle), -sin(angle))
    _knockback_force = dir * KNOCKBACK_FORCE
    var time = 0.12
    if _target.dead:
        time *= 1.5
        _knockback_force *= 1.5
    _knockback_force *= _knockback_mod
    time *= _knockback_air_mod
    _knockback_air_mod = 1
    _knockback_mod = 1
    knockback_tween.interpolate_property(self, "_knockback_force", _knockback_force, Vector2(), time,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    knockback_tween.start()

func _clear_attack(reset_combo=true):
    if reset_combo && len(_current_hit_targets) == 0:
        reset_combo()
    _current_hit_targets.clear()
    _target = null
    _attack_state = IDLE
    hitbox.disabled = true
    _interuppted = false

func _on_cooldown_finished():
    if _attack_state == ATTACKING:
        _clear_attack()

func _on_animation_finished(anim):
    _clear_attack()

