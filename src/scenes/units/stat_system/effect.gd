
var identifier
var modifier
var _duration
var _interval
var _affected
var _elapsed_time = 0.0
var to_expire = false
var _last_tick = 0
var _last_second = 0
var _start_value
var _start_duration

func _init(p_identifier, p_affected, p_modifier, p_duration=null, p_interval=null):
    identifier = p_identifier
    modifier = p_modifier
    _start_value = modifier.value
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
    var is_health = modifier.stat == STAT.HEALTH
    var is_endur = modifier.stat == STAT.ENDURANCE
    if is_health || is_endur:
        _affected.damage(modifier.value, null, true) if is_health else _affected.fatigue(modifier.value, null, true)
        return
    modifier.value += _start_value

func refresh():
    if not _duration: return
    if _duration - _last_second + 1 != _start_duration:
        _duration = _start_duration + _last_second + 1

func compare(p_effect):
    return identifier == p_effect.identifier && _start_value == p_effect.modifier.value && modifier.mod == p_effect.modifier.mod && modifier.stat == p_effect.modifier.stat

func _expire(flag):
    to_expire = flag