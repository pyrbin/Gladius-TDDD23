extends "../motion.gd"

func handle_input(event):
    if event.is_action_pressed("jump"):
        emit_signal("finished", "jump")
    var lmb = event.is_action_pressed("left_attack")
    var rmb = event.is_action_pressed("right_attack")
    if owner.is_weapon_ready() and lmb:
        owner.left_attack_weapon();
    return .handle_input(event)