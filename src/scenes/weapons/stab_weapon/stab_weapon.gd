extends "../weapon.gd"

func _ready():
	wep_sprite.set_flip_v(false)

func _setup():
	pass

func _action_attack():
	anim_player.play("stab")

func _on_body_entered(body):
	if _current_hit_targets.size() > 1:
		return
	else:
		._on_body_entered(body)

