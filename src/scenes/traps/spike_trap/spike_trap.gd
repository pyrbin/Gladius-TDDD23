extends "res://scenes/traps/trap.gd"

onready var activated_timer = $Activated
onready var downtime_timer = $Downtime

func _ready():
    activated = false
    downtime_timer.start()

func trigger(unit):
    if !unit.has_method("damage"): return
    if unit.has_iframe(): return
    unit.damage(10, self, true, true);
    unit.stats.add_effect(\
    Effect.new("Trap Bleed", unit, \
        Modifier.new(STAT.HEALTH, STAT.VALUE, 5),\
     5, 1))


func _on_Downtime_timeout():
    activated = true
    anim_player.play("trigger")

func _on_AnimationPlayer_animation_finished(anim_name):
    activated = false
    downtime_timer.start()
