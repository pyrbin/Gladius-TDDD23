
var stat
var vsum = 0.0
var msum = 0.0

func _init(p_stat):
    stat = p_stat

func add(p_modifier):
    if p_modifier.mod == STAT.PERCENT:
        msum += p_modifier.value
    elif p_modifier.mod == STAT.VALUE:
        vsum += p_modifier.value
        
func compute(p_value):
    return (p_value * (1 + (msum/100.0))) + vsum