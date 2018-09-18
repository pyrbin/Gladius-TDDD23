extends "../weapon.gd"

func _ready():
	wep_sprite.set_flip_v(false)

func attack_lmb():
	anim_player.play("stab")

func attack_rmb():
#match swing_state:
#		DOWN:
#			anim_player.play("stab_down")
#		UP:
#			anim_player.play("stab_up")
	pass

func _on_body_entered(body):
	print(_current_hit_targets.size())
	if _current_hit_targets.size() > 1:
		return
	else:
		._on_body_entered(body)


func attack(type):
	if not is_ready():
		return

	if type == 0:
		attack_lmb()
	else:
		attack_rmb()

	return .attack(type)

