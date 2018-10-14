extends "res://scenes/traps/trap.gd"

func _ready():
    activated = true

func trigger(unit):
    unit.stats.add_effect(\
    Effect.new("Burn", unit, \
        Modifier.new(STAT.HEALTH, STAT.VALUE, 6),\
     2, 1))
