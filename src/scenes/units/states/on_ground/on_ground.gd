extends "../motion.gd"

const JUMP_COST = 10    
const BASH_COST = 10

const Effect = preload("../../stat_system/effect.gd")
const Modifier = preload("res://data/modifier.gd")

func _ready():
    owner.connect("took_damage", self, "_on_took_damage")
    owner.connect("staggered", self, "_on_staggered")

func handle_input(event):
    var attack = event.is_action_pressed("attack")
    var bash = event.is_action_pressed("block")
    var interact = event.is_action_pressed("interact")
    var special = event.is_action_pressed("special")
    var jump = event.is_action_pressed("jump")
    
    if attack && not owner.bashing:
        owner.attack_weapon()

    elif interact:
        owner.on_interact()
        
    if special:
        owner.use_consumable()

    if bash && owner.status.endurance >= BASH_COST && owner.bash_timer.is_stopped() && not owner.bashing:
        var flag = true if not owner.weapon else (owner.weapon.is_idle() || owner.weapon.is_holstered()) 
        if flag:
            owner.status.fatigue(BASH_COST)
            owner.bash();

    if jump && owner.status.endurance >= JUMP_COST:
        owner.status.fatigue(JUMP_COST)
        emit_signal("finished", "jump")
        
    return .handle_input(event)


func _on_staggered(actor):
    emit_signal("finished", "stagger")

func _on_took_damage(amount, actor, soft):
    if not soft:
        emit_signal("finished", "stagger")
    elif amount > 0:
        owner.get_node("SpritePlayer").play("stagger")
