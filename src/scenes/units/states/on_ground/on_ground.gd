extends "../motion.gd"

const Effect = preload("../../stat_system/effect.gd")
const Modifier = preload("res://data/modifier.gd")

func _ready():
    owner.connect("took_damage", self, "_on_took_damage")

func handle_input(event):
    var lmb = event.is_action_pressed("attack")
    var rmb = event.is_action_pressed("block")
    var interact = event.is_action_pressed("interact")
    var consumable = event.is_action_pressed("special")

    if lmb:
        owner.attack_weapon()
    elif interact:
        owner.on_interact()
    if consumable:
        owner.stats.add_effect(Effect.new("test", owner, Modifier.new(STAT.MOVEMENT, STAT.PERCENT, 20), 10, 2))
        # owner.use_consumable()
    if rmb:
        owner.try_block();

    if event.is_action_pressed("jump") && owner.status.endurance >= 20:
        owner.status.fatigue(20)
        emit_signal("finished", "jump")
        
    return .handle_input(event)

func _on_took_damage(amount, actor, soft):
    if not soft:
        emit_signal("finished", "stagger")
    elif amount > 0:
        owner.get_node("SpritePlayer").play("stagger")
