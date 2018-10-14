extends "res://scenes/traps/trap.gd"

func _ready():
    activated = true

func trigger(unit):
    if !unit.has_method("damage"): return
    var effect = Effect.new("Burn", unit, Modifier.new(STAT.HEALTH, STAT.VALUE, 3), 2, 1)
    var has_effect = unit.stats.add_effect(effect)
    if not has_effect:
        $OnHitPlayer.play()