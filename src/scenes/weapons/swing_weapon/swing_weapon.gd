extends "../weapon.gd"

enum SWING_STATE {UP, DOWN}

var swing_state = DOWN

func _ready():
	wep_sprite.set_flip_v(false)

func set_reach(offset):
	return .set_reach(offset)

func attack_lmb():
	match swing_state:
		DOWN:
			anim_player.play("swing_down")
			swing_state = UP
		UP:
			anim_player.play("swing_up")
			swing_state = DOWN

func attack_rmb():
#match swing_state:
#		DOWN:
#			anim_player.play("stab_down")
#		UP:
#			anim_player.play("stab_up")
	pass


func attack(type):
	if not is_ready():
		return

	if type == 0:
		attack_lmb()
	else:
		attack_rmb()

	return .attack(type)

