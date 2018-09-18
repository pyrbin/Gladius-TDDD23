extends "../motion.gd"

func _ready():
    owner.connect("took_damage", self, "_on_took_damage")

func handle_input(event):
    var lmb = event.is_action_pressed("left_attack")
    var rmb = event.is_action_pressed("right_attack")
    var interact = event.is_action_pressed("interact")

    if lmb:
        owner.left_attack_weapon();
    elif interact:
        owner.on_interact();
    if rmb:
        owner.right_attack_weapon();

    if event.is_action_pressed("jump") && owner.stats.final_stat("ENDURANCE") >= 20:
        owner.stats.mod_modifier("ENDURANCE", -20, "VALUE")
        emit_signal("finished", "jump")
        
    return .handle_input(event)

func _on_took_damage(amount, actor):
    emit_signal("finished", "stagger")
