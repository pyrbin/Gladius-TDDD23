extends "../weapon.gd"

enum SWING_STATE {UP, DOWN}

var swing_state = DOWN

func _ready():
	wep_sprite.set_flip_v(false)

func set_reach(offset):
	var stab_d = anim_player.get_animation("stab_down")
	var stab_u = anim_player.get_animation("stab_up")
	# 0 , 1 , 3
	var d_id_pos = stab_d.find_track("Pivot/Area2D:position")
	var u_id_pos = stab_u.find_track("Pivot/Area2D:position")

	for i in range (0, 3):
		if i == 2:
			continue
		stab_d.track_set_key_value(d_id_pos, i, offset)
		stab_u.track_set_key_value(u_id_pos, i, offset)

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
	body.move_and_slide(dir * 3500)
