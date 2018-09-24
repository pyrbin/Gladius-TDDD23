
var stat
var _perc[], _vals[]

func _init(p_stat):
    stat = p_stat

func add(p_modifier):
    var list = _perc if mod == "PERCENT" else _vals
    list.append(val)

func compute(p_value):
    var vsum, msum
    for v in _vals: vsum += v
    for p in _perc: msum += p
    return (p_value * msum) + vsum