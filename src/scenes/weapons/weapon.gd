extends Node

enum ATTACK_STATE { IDLE, ATTACKING, HOLSTERED }

const WeaponData = preload("res://data/weapon_data.gd")
const HITABLE_GROUP_NAME = "Hitable"
const KNOCKBACK_FORCE = 1600
export (Vector2) var holster_offset = Vector2(52,0)

onready var cooldown_timer = $Timer

# Data
var data
var is_loaded

# Visuals
onready var wep_sprite = $Pivot/Area2D/Sprite
onready var anim_player = $AnimationPlayer
onready var u_hand_pivot = $Pivot/Area2D/Sprite/U_Hand_Pivot
onready var l_hand_pivot = $Pivot/Area2D/Sprite/L_Hand_Pivot

var attack_state = IDLE
var holder = null
var _current_hit_targets = []

func set_holstered(b):
    hide() if b else show()
    attack_state = HOLSTERED if b else IDLE

func load_weapon(weapon_data):
    data = weapon_data
    wep_sprite.set_texture(load(data.sprite))
    anim_player.playback_speed = 1/(data.attributes["ATTACK_SPEED"]/1000.0)
    cooldown_timer.wait_time = data.attributes["COOLDOWN"]
    is_loaded = true

func _ready():
    $Pivot/Area2D/Hitbox.disabled = true
    $Pivot/Area2D.connect("body_entered", self, "_on_body_entered_root")
    anim_player.connect("animation_finished", self, "_on_animation_finished")

func set_reach(offset):
    $Pivot/Area2D.position = Vector2(offset, $Pivot/Area2D.position.y)

func is_ready():
    return attack_state == IDLE && cooldown_timer.is_stopped() && is_loaded

func is_idle():
    return attack_state == IDLE && is_loaded

func is_holstered():
    return attack_state == HOLSTERED && is_loaded

func attack_lmb():
    pass
func attack_rmb():
    pass
    
func attack(type):
    if not is_loaded: return
    $Pivot/Area2D/Hitbox.disabled = false
    attack_state = ATTACKING
    cooldown_timer.start()

func is_hitable(body):
    return body != holder and body.is_in_group(HITABLE_GROUP_NAME) and !_current_hit_targets.has(body)

func _on_body_entered_root(body):
    if not is_hitable(body) or attack_state != ATTACKING:
        return
    _current_hit_targets.append(body)
    _on_body_entered(body)

func _on_body_entered(body):
    var angle = holder.position.angle_to_point(holder.get_aim_position())
    var dir = Vector2(-cos(angle), -sin(angle))
    body.velocity = dir * KNOCKBACK_FORCE
    body.take_damage(data.attributes["DAMAGE"], owner)

func _on_animation_finished(anim):
    _current_hit_targets.clear()
    $Pivot/Area2D/Hitbox.disabled = true
    attack_state = IDLE
