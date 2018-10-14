
var identifier
var modifiers = []
var _start_values = []
var _duration
var _interval
var _affected
var _elapsed_time = 0.0
var to_expire = false
var _last_tick = 0
var _last_second = 0
var _start_duration
var _one_time = false
var _first_tick = false
var _refreshed = false

func _init(p_identifier, p_affected, p_modifiers, p_duration=null, p_interval=null):
    identifier = p_identifier
    _affected = p_affected

    if typeof(p_modifiers) == TYPE_ARRAY:
        for mod in p_modifiers:
            modifiers.append(mod)
            _start_values.append(mod.value)
    else:
        modifiers.append(p_modifiers)
        _start_values.append(p_modifiers.value)

    if p_duration && p_duration != 0:
        _duration =  ceil(p_duration)
        _start_duration = _duration
    if p_interval && p_interval != 0:
        _interval = ceil(p_interval)
    else:
        _one_time = true

func get_progress():
    if _duration == null:
        return 1
    return _elapsed_time/_duration

func get_duration():
    return _start_duration

func update(delta, affected):

    if not _first_tick && not _one_time && _interval:
        _first_tick = true
        _trigger()
        
    if not _interval && _one_time:
        _trigger()
        _one_time = false
        if not _duration || _duration == 0:
            to_expire = true

    if to_expire: return
    _affected = affected
    _elapsed_time += delta
    _last_second = int(_elapsed_time)
    if _interval && int(_last_second) % int(_interval) == 0 && _last_tick != _last_second:
        _last_tick = _last_second
        _trigger()
    if _duration && _last_second == _duration:
        _expire(true)

func _trigger():
    for i in range(0, modifiers.size()):
        var modifier = modifiers[i]
        if modifier.stat == STAT.HEALTH:
            _affected.soft_damage(modifier.value, null)
        elif modifier.stat == STAT.ENDURANCE:
            _affected.fatigue(modifier.value, null, true)
        elif not _one_time:
            modifier.value += _start_values[i]

func refresh():
    _refreshed = true
    if not _duration: return
    if _duration - _last_second != _start_duration:
        _duration = _start_duration + _last_second

func compare(p_effect):
    if p_effect.modifiers.size() != modifiers.size():
        return false
    for i in range(0, modifiers.size()):
        if modifiers[i].stat != p_effect.modifiers[i].stat \
            || _start_values[i] != p_effect.modifiers[i].value \
            || modifiers[i].mod != p_effect.modifiers[i].mod:
            return false
    return identifier == p_effect.identifier

func _expire(flag):
    to_expire = flag