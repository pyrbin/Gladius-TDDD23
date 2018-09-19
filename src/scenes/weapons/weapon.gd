extends Node

export (Vector2) var holster_offset = Vector2(52,0)

enum ATTACK_STATE { IDLE, ATTACKING, HOLSTERED }

const WeaponData = preload("res://data/weapon_data.gd")
const HITABLE_GROUP_NAME = "Hitable"
const KNOCKBACK_FORCE = 200

onready var wep_sprite = $Pivot/Area2D/Sprite
onready var anim_player = $AnimationPlayer
onready var u_hand_pivot = $Pivot/Area2D/Sprite/U_Hand_Pivot
onready var l_hand_pivot = $Pivot/Area2D/Sprite/L_Hand_Pivot
onready var knockback_tween = $KnockbackTween
onready var cooldown_timer = $Timer

var data = null
var holder = null

var _is_loaded = false
var _attack_state = IDLE
var _knockback_force = Vector2()

var _target = null
var _current_hit_targets = []

func _ready():
    $Pivot/Area2D.connect("body_entered", self, "_on_body_entered_root")
    anim_player.connect("animation_finished", self, "_on_animation_finished")

func _physics_process(d):
    if knockback_tween.is_active() && _target:
        _target.velocity = _knockback_force

func set_holstered(b):
    hide() if b else show()
    _attack_state = HOLSTERED if b else IDLE

func load_weapon(weapon_data):
    data = weapon_data
    wep_sprite.set_texture(load(data.sprite))
    anim_player.playback_speed = 1/(data.attributes["ATTACK_SPEED"]/1000.0)
    cooldown_timer.wait_time = data.attributes["COOLDOWN"]
    _is_loaded = true

func set_reach(offset):
    $Pivot/Area2D.position = Vector2(offset, $Pivot/Area2D.position.y)

func is_ready():
    return _attack_state == IDLE && cooldown_timer.is_stopped() && _is_loaded

func is_idle():
    return _attack_state == IDLE && _is_loaded

func is_holstered():
    return _attack_state == HOLSTERED && _is_loaded

func attack_lmb():
    pass
func attack_rmb():
    pass
    
func attack(type):
    if not _is_loaded: return false
    _attack_state = ATTACKING
    cooldown_timer.start()
    return true

func is_hitable(body):
    return body != holder and body.is_in_group(HITABLE_GROUP_NAME) and !_current_hit_targets.has(body) and not body.iframe

func _on_body_entered_root(body):
    if _attack_state != ATTACKING: return
    if not is_hitable(body): return
    _current_hit_targets.append(body)
    _on_body_entered(body)

func _on_body_entered(body):
    _target = body
    _target.deal_damage(data.attributes["DAMAGE"], self)
    if holder == get_tree().get_nodes_in_group("Player")[0]:
        gb_Utils.freeze_time(0.075)
        holder.camera.shake(0.25, 20, 3.5)
    if body != get_tree().get_nodes_in_group("Player")[0]:
        _knockback()

func _knockback():
    var angle = holder.position.angle_to_point(holder.get_aim_position())
    var dir = Vector2(-cos(angle), -sin(angle))
    _knockback_force = dir * KNOCKBACK_FORCE
    var time = 0.12
    if _target.dead:
        time *= 1.5
        _knockback_force *= 1.5
    knockback_tween.interpolate_property(self, "_knockback_force", _knockback_force, Vector2(), time,
        Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    knockback_tween.start()

func _on_animation_finished(anim):
    _current_hit_targets.clear()
    _target = null
    _attack_state = IDLE
