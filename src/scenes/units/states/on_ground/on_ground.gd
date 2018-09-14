extends "../motion.gd"


func handle_input(event):
    var lmb = event.is_action_pressed("left_attack")
    var rmb = event.is_action_pressed("right_attack")
    var interact = event.is_action_pressed("interact")

    if lmb:
        owner.left_attack_weapon();
    elif interact:
        owner.on_interact();
   # if rmb:
   #    owner.right_attack_weapon();

    if event.is_action_pressed("jump"):
        emit_signal("finished", "jump")
        
    return .handle_input(event)

