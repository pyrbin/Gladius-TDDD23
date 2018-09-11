extends "../weapon.gd"

enum SWING_STATE {UP, DOWN}

var swing_state = DOWN

func _ready():
	weapon_type = SWING
	wep_sprite.set_flip_v(false)

func attack_lmb():
	match swing_state:
		DOWN:
			anim_player.play("swing_down")
			swing_state = UP
		UP:
			anim_player.play("swing_up")
			swing_state = DOWN

func attack_rmb():
	match swing_state:
		DOWN:
			anim_player.play("stab_down")
		UP:
			anim_player.play("stab_up")

func attack(type):
	if not is_ready():
		return

	if type == 0:
		attack_lmb()
	else:
		attack_rmb()

	return .attack(type)

func _on_body_entered(body):
	var angle = holder.position.angle_to_point(holder.get_aim_position())
	var dir = Vector2(-cos(angle), -sin(angle))
	body.velocity = dir * 3500
