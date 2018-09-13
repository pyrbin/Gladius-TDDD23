extends "../motion.gd"


func handle_input(event):
    var lmb = event.is_action_pressed("left_attack")
    var rmb = event.is_action_pressed("right_attack")

    if lmb:
        owner.left_attack_weapon();

   # if rmb:
   #    owner.right_attack_weapon();

    if event.is_action_pressed("jump"):
        emit_signal("finished", "jump")
        
    return .handle_input(event)

