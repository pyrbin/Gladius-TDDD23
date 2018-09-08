extends "../weapon.gd"

enum SWING_STATE {UP, DOWN}

var swing_state = DOWN

func _ready():
	wep_sprite.set_flip_v(false)

func attack():
	match swing_state:
		DOWN:
			anim_player.play("swing_down")
			swing_state = UP
		UP:
			anim_player.play("swing_up")
			swing_state = DOWN
	return .attack()