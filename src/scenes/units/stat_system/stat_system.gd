extends Node

export (float) var vitality = 0
export (float) var stamina = 0
export (float) var power = 0
export (float) var attack_speed = 0
export (float) var movement_speed = 0
export (float) var crit_chance = 0

const FinalStat = preload("final_stat.gd")

var _effects = []
var _stats = {
    STAT.VITALITY  : 0.0,
    STAT.STAMINA   : 0.0,
    STAT.POWER     : 0.0,
    STAT.ATK_SPEED : 0.0,
    STAT.MOVEMENT  : 0.0,
    STAT.CRIT      : 0.0
}

func _ready():
    _effects.resize(30)
    _stats = {
        STAT.VITALITY  : vitality,
        STAT.STAMINA   : stamina,
        STAT.POWER     : power,
        STAT.ATK_SPEED : attack_speed,
        STAT.MOVEMENT  : movement_speed,
        STAT.CRIT      : crit_chance
    }

func _process(d):
    for i in range(0, _effects.size()):
        var effect = _effects[i]
        if effect == null: continue
        effect.update(d)
        if effect.to_expire:
            _effects[i] = null

func add_effect(p_effect):
    var found = null
    for i in range(0, _effects.size()):
        var effect = _effects[i]
        if effect == null: continue
        if effect.compare(p_effect):
            found = effect
 
    if found:
        found.refresh()
    else:
        _effects.append(p_effect)

func del_effect_by_id(p_identifier):
    for i in range(0, _effects.size()):
        if _effects[i].identifier == p_identifier:
            _effects[i] = null

func del_effect(p_effect):
    _effects[_effects.find(p_effect)] == null

func get_stat_info(p_stat):
    var final = FinalStat.new(p_stat)
    for effect in _effects:
        if effect == null: continue
        for mod in effect.modifiers:
            if mod.stat == p_stat:
                final.add(mod)
    _add_stat_from_list(final, p_stat, owner.action_equipment.get_list())
    _add_stat_from_list(final, p_stat, owner.equipment.get_list())
    return final

func _add_stat_from_list(p_final, p_stat, p_list):
    for it in p_list:
        if it == null: 
            continue
        var item = gb_ItemDatabase.get_item(it)
        for k_stats in item.stats:
            if k_stats != p_stat: continue
            var modifiers = item.stats[k_stats]
            for mod in modifiers:
                p_final.add(mod)

func get_stat(p_stat):
    return get_stat_info(p_stat).compute(get_base_stat(p_stat))

func get_list():
    return _stats.keys()

func get_base_stat(p_stat):
    return _stats[p_stat]