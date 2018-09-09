extends "../weapon.gd"

enum SWING_STATE {UP, DOWN}

var swing_state = DOWN

func _ready():
	weapon_type = SWING
	wep_sprite.set_flip_v(false)

func attack():
	if not is_ready():
		return

	match swing_state:
		DOWN:
			anim_player.play("swing_down")
			swing_state = UP
		UP:
			anim_player.play("swing_up")
			swing_state = DOWN
	return .attack()

func _on_body_entered(body):
	var angle = holder.position.angle_to_point(holder.get_aim_position())
	var dir = Vector2(-cos(angle), -sin(angle))
	body.velocity = dir * 3500
	