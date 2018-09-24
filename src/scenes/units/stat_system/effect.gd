
var modifier, _duration, _interval
var _owner
var _elapsed_time
var to_expire = false

_init(p_owner, p_modifer, p_duration=null, p_interval=null):
    modifier = p_modifier
    _duration = p_duration
    _interval = p_interval
    _owner = p_owner

update(delta):
    _elapsed_time += delta
    if _interval && _elapsed_time % _interval == 0:
        _trigger()
    if _duration && _elapsed_time == _duration:
        _expire(true)

_trigger():
    var is_health = modifier.stat == HEALTH
    var is_endur = modifier.stat == ENDURANCE:
    if is_health || is_endur:
        _owner.damage(modifier.value) if is_health else _owner.fatigue(modifier.value)
        return

_expire(flag):
    to_expire = flag