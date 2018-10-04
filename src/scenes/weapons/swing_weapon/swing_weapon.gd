extends "../weapon.gd"

enum SWING_STATE {UP, DOWN}
const Effect = preload("res://scenes/units/stat_system/effect.gd")
const Modifier = preload("res://data/modifier.gd")
var swing_state = DOWN

func _ready():
	wep_sprite.set_flip_v(false)

func _action_ult_attack():
	match swing_state:
		DOWN:
			anim_player.play("swing_down_ult")
			swing_state = UP
			#anim_player.queue("swing_up_ult")
			#swing_state = DOWN
		UP:
			anim_player.play("swing_up_ult")
			swing_state = DOWN
			#anim_player.queue("swing_down_ult")
			#swing_state = UP

func _action_attack():
	match swing_state:
		DOWN:
			anim_player.play("swing_down")
			swing_state = UP
		UP:
			anim_player.play("swing_up")
			swing_state = DOWN