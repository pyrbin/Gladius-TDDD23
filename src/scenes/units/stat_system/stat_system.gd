extends Node

export (float) var vitality = 0
export (float) var stamina = 0
export (float) var power = 0
export (float) var attack_speed = 0
export (float) var movement_speed = 0
export (float) var crit_chance = 0

signal effect_applied(effect)
signal effect_expired(effect)

const FinalStat = preload("final_stat.gd")
const Effect = preload("effect.gd")
const Modifier = preload("res://data/modifier.gd")

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
    _effects.resize(16)
    _stats = {
        STAT.VITALITY  : vitality,
        STAT.STAMINA   : stamina,
        STAT.POWER     : power,
        STAT.ATK_SPEED : attack_speed,
        STAT.MOVEMENT  : movement_speed,
        STAT.CRIT      : crit_chance
    }

func _process(d):
    for i in range(0, len(_effects)):
        if i > len(_effects) - 1: continue
        var effect = _effects[i]
        if effect == null: continue
        effect.update(d, owner)
        if effect.to_expire && _effects.size() > i:
            _effects[i] = null
            emit_signal("effect_expired", effect)
    _effects.sort_custom(SortByCooldown, "sort")

func add_effect(p_effect):
    var found = null
    var first_empty = -1
    for i in range(0, _effects.size()):
        var effect = _effects[i]
        if effect == null: 
            if first_empty == -1:
                first_empty = i
            continue
        if effect.compare(p_effect):
            found = effect
    if found != null:
        found.refresh()
    elif first_empty != -1:
        _effects[first_empty] = p_effect
    emit_signal("effect_applied", p_effect)


func add_effect_fac(p_name, p_stat, p_val, p_mod=STAT.VALUE, p_duration=null, p_interval=null):
    add_effect(Effect.new(p_name, owner, Modifier.new(p_stat, p_mod, p_val), p_duration, p_interval))
    
func del_effect_by_id(p_identifier):
    for i in range(0, _effects.size()):
        if _effects[i].identifier == p_identifier:
            _effects[i] = null

func del_effect(p_effect):
    _effects[_effects.find(p_effect)] == null

func get_stat_info(p_stat):
    var final = FinalStat.new(p_stat)
    for i in range(0, len(_effects)):
        var effect = _effects[i]
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

class SortByCooldown:
    static func sort(a, b):
        if a == null: return false
        if b == null: return true
        if a.get_progress() > b.get_progress():
            return true

func get_stat(p_stat):
    return get_stat_info(p_stat).compute(get_base_stat(p_stat))

func get_list():
    return _stats.keys()

func get_effects():
    var tmp = []
    for efx in _effects:
        if efx == null: continue
        tmp.append(efx)
    return tmp    

func clear_effects():
    _effects.clear()

func get_base_stat(p_stat):
    return _stats[p_stat]