extends Node

enum ATTACK_STATE { IDLE, ATTACKING }

var attack_state = IDLE

onready var anim_player = get_node("AnimationPlayer")
onready var wep_sprite = get_node("Pivot/Area/Sprite")

func _ready():
	anim_player.connect("animation_finished", self, "_on_animation_finished")

func attack():
	attack_state = ATTACKING

func _on_animation_finished(anim):
	attack_state = IDLE