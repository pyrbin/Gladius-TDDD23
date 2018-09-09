extends Node

enum ATTACK_STATE { IDLE, ATTACKING }

var attack_state = IDLE

onready var anim_player = $AnimationPlayer
onready var wep_sprite = $Pivot/Area/Sprite

onready var u_hand_pivot = $Pivot/Area/Sprite/U_Hand_Pivot
onready var l_hand_pivot = $Pivot/Area/Sprite/L_Hand_Pivot

func _ready():
	anim_player.connect("animation_finished", self, "_on_animation_finished")

func attack():
	attack_state = ATTACKING

func _on_animation_finished(anim):
	attack_state = IDLE