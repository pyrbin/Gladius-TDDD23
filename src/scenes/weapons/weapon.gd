extends Node

enum ATTACK_STATE { IDLE, ATTACKING }
enum WEAPON_TYPE { SWING, STAB, RANGED }

export (String) var weapon_name = ""
export (WEAPON_TYPE) var weapon_type = SWING

const HITABLE_GROUP_NAME = "Hitable"

onready var anim_player = $AnimationPlayer
onready var cooldown_timer = $Timer
onready var wep_sprite = $Pivot/Area2D/Sprite
onready var u_hand_pivot = $Pivot/Area2D/Sprite/U_Hand_Pivot
onready var l_hand_pivot = $Pivot/Area2D/Sprite/L_Hand_Pivot

var attack_state = IDLE
var holder = null

var _current_hit_targets = []

func _ready():
    $Pivot/Area2D/Hitbox.disabled = true
    $Pivot/Area2D.connect("body_entered", self, "_on_body_entered_root")
    anim_player.connect("animation_finished", self, "_on_animation_finished")

func is_ready():
    return attack_state == IDLE && cooldown_timer.is_stopped()

func is_idle():
    return attack_state == IDLE

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
