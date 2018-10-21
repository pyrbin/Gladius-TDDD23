extends "res://scenes/traps/trap.gd"

export (int) var impact_damage = 3
export (int) var dot_damage = 1
export (float) var delay = 3

onready var downtime_timer = $Downtime

func _ready():
    activated = false
    collision.disabled = not activated
    downtime_timer.wait_time = delay
    downtime_timer.start()

func trigger(unit):
    if !unit.has_method("damage"): return
    var hit = unit.damage(impact_damage, self, true);
    if not hit: return
    $OnHitPlayer.play()
    _targets.remove(_targets.find(unit))
    yield(utils.timer(0.5), "timeout")
    unit.stats.add_effect(\
    Effect.new("Trap Bleed", unit, \
        Modifier.new(STAT.HEALTH, STAT.VALUE, dot_damage),\
     4, 1))

func _on_Downtime_timeout():
    emit_signal("trigger")
    activated = true
    collision.disabled = not activated
    anim_player.play("trigger")
    $TriggerPlayer.play()

func _on_Trap_body_entered(body):
    return ._on_Trap_body_entered(body)
    
func _on_Trap_body_exited(body):
    return ._on_Trap_body_exited(body)

func _on_AnimationPlayer_animation_finished(anim_name):
    activated = false
    collision.disabled = not activated
    downtime_timer.start()
