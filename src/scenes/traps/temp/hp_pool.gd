extends "res://scenes/traps/trap.gd"

func _ready():
    activated = true

func trigger(unit):
    unit.stats.add_effect(\
    Effect.new("Trap Heal", unit, \
        Modifier.new(STAT.HEALTH, STAT.VALUE, -5),\
     5, 1))
