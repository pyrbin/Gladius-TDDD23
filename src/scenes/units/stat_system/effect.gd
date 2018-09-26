
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

func _init(p_identifier, p_affected, p_modifiers, p_duration=null, p_interval=null):
    identifier = p_identifier
    
    if typeof(p_modifiers) == TYPE_ARRAY:
        for mod in p_modifiers:
            modifiers.append(mod)
            _start_values.append(mod.value)
    else:
        modifiers.append(p_modifiers)
        _start_values.append(p_modifiers.value)

    if p_duration:
        _duration =  int(p_duration)
        _start_duration = _duration
    if p_interval:
        _interval = int(p_interval)
    _affected = p_affected

func get_progress():
    return _elapsed_time/_duration

func get_duration():
    return _start_duration

func update(delta):
    _elapsed_time += delta
    _last_second = int(_elapsed_time)
    if _interval && _last_second % _interval == 0 && _last_tick != _last_second:
        _last_tick = _last_second
        _trigger()
    if _duration && _last_second == _duration:
        _expire(true)

func _trigger():
    for i in range(0, modifiers.size()):
        var modifier = modifiers[i]
        var is_health = modifier.stat == STAT.HEALTH
        var is_endur = modifier.stat == STAT.ENDURANCE
        if is_health || is_endur:
            _affected.damage(modifier.value, null, true) if is_health else _affected.fatigue(modifier.value, null, true)
            return
        modifier.value += _start_values[i]

func refresh():
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