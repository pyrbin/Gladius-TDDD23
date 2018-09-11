extends Node

enum ATTACK_STATE { IDLE, ATTACKING, HOLSTERED }

const HITABLE_GROUP_NAME = "Hitable"
const HOLSTER_OFFSET = Vector2(0,0)
onready var cooldown_timer = $Timer

# Data
onready var data = $Data

# Visuals
onready var wep_sprite = $Pivot/Area2D/Sprite
onready var anim_player = $AnimationPlayer
onready var u_hand_pivot = $Pivot/Area2D/Sprite/U_Hand_Pivot
onready var l_hand_pivot = $Pivot/Area2D/Sprite/L_Hand_Pivot

var attack_state = IDLE
var holder = null
var _current_hit_targets = []

func set_holstered(b):
    if b:
        attack_state = HOLSTERED
        $Pivot/Area2D.rotation = 0
        $Pivot.rotation = 0
        $Pivot.position = Vector2(0,0)
        $Pivot/Area2D.position = Vector2(0,0) + HOLSTER_OFFSET
    else:
        attack_state = IDLE

func _ready():
    $Pivot/Area2D/Hitbox.disabled = true
    anim_player.playback_speed = 1/(data.speed/1000)
    cooldown_timer.wait_time = data.cooldown
    $Pivot/Area2D.connect("body_entered", self, "_on_body_entered_root")
    anim_player.connect("animation_finished", self, "_on_animation_finished")

func set_reach(offset):
    $Pivot/Area2D.position = Vector2(offset, $Pivot/Area2D.position.y)

func is_ready():
    return attack_state == IDLE && cooldown_timer.is_stopped()

func is_idle():
    return attack_state == IDLE

func is_holstered():
    return attack_state == HOLSTERED

func attack_lmb():
    pass
func attack_rmb():
    pass
    
func attack(type):
    $Pivot/Area2D/Hitbox.disabled = false
    attack_state = ATTACKING
    cooldown_timer.start()

func is_hitable(body):
    return body != holder and body.is_in_group(HITABLE_GROUP_NAME) and !_current_hit_targets.has(body)

func _on_body_entered_root(body):
    if not is_hitable(body):
        return
    _current_hit_targets.append(body)
    _on_body_entered(body)

func _on_body_entered(body):
    pass

func _on_animation_finished(anim):
    $Pivot/Area2D/Hitbox.disabled = true
    _current_hit_targets.clear()
    attack_state = IDLE
