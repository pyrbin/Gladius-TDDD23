extends Node

export (float) var vitality = 0
export (float) var stamina = 0
export (float) var power = 0
export (float) var attack_speed = 0
export (float) var movement_speed = 0
export (float) var crit_chance = 0

var _effects = []
var _stats = {
    STAT.VITALITY  : 0.0,
    STAT.STAMINA   : 0.0,
    STAT.POWER     : 0.0,
    STAT.ATK_SPEED : 0.0,
    STAT.MOV_SPEED : 0.0,
    STAT.CRIT      : 0.0
}

func _process_physics(d):
    for i in range(0, _effects):
        var effect = _effects[i]
        effect.update(d)
        if effect.to_expire:
            _effects.remove(i)

func get_stat(p_stat):
    var value = FinalStat.new(p_stat)
    for effect in _effects:
        value.add(effect.modifier)
    for it in owner.equipment:
        for mod in it.modifiers:
            if mod.stat != p_stat: continue
            value.add(mod)
    return value.compute(_stats[p_stat])