extends "../weapon.gd"

export (int) var stab_length = 0

func _setup():
	wep_sprite.set_flip_v(false)
	anim_player.get_animation("stab").track_set_key_value(0, 1, Vector2(stab_length, 0))

func _action_attack():
	anim_player.play("stab")

func _on_body_entered(body):
	if _current_hit_targets.size() > 1:
		return
	else:
		._on_body_entered(body)