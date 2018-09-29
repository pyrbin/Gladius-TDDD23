extends "res://scenes/traps/trap.gd"
onready var downtime_timer = $Downtime

func _ready():
    activated = false
    collision.disabled = not activated
    downtime_timer.start()

func trigger(unit):
    if !unit.has_method("damage"): return
    var hit = unit.damage(10, self, true);
    if not hit: return
    unit.stats.add_effect(\
    Effect.new("Trap Bleed", unit, \
        Modifier.new(STAT.HEALTH, STAT.VALUE, 5),\
     5, 1))
    _targets.remove(_targets.find(unit))

func _on_Downtime_timeout():
    activated = true
    collision.disabled = not activated
    anim_player.play("trigger")

func _on_AnimationPlayer_animation_finished(anim_name):
    activated = false
    collision.disabled = not activated
    downtime_timer.start()
