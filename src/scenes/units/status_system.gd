extends Node

signal on_health_zero
signal on_revive

# Start values
export (int, FLAGS, "Health Regen", "Endurance Regen", "Use Stats") var status_settings = 0

export (float) var health = 100.0
export (float) var endurance = 100.0

export (float) var max_health = 100.0
export (float) var max_endurance = 100.0

export (float) var endurance_regen = 3.0
export (float) var health_regen = 3.0

var regenerating_health = false
var regenerating_endurance = false

var _max_health_cache = 0
var _max_endurance_cache = 0


func _ready():
    set_process(true)
    $EnduranceRegen.connect("timeout", self, "_on_regen_endurance")
    $HealthRegen.connect("timeout", self, "_on_regen_health")
    _max_health_cache = max_health
    _max_endurance_cache = max_endurance

func damage(amount):
    var hp = health
    health = round(clamp(health-amount, 0, get_max_health()))
    if health == 0:
        emit_signal("on_health_zero")
    if hp == 0 && health > hp:
        emit_signal("on_revive")

func fatigue(amount):
    endurance = round(clamp(endurance-amount, 0, get_max_endurance()))

func get_max_health():
    var use_stats = gb_Utils.is_bit_enabled(status_settings, 2)
    return round(max_health) if not use_stats else round(max_health+owner.stats.get_stat(STAT.VITALITY)) 

func get_max_endurance():
    var use_stats = gb_Utils.is_bit_enabled(status_settings, 2)
    return round(max_health) if not use_stats else round(max_endurance+owner.stats.get_stat(STAT.STAMINA)) 

func get_health_perc():
    return health/get_max_health()

func _on_regen_endurance():
    fatigue(-endurance_regen)

func _on_regen_health():
    damage(-health_regen)

func _process(d):
    if gb_Utils.is_bit_enabled(status_settings, 0):   
        if health < get_max_health() && !regenerating_health:
            regenerating_health = true
            $HealthRegen.start()
        elif health >= get_max_health(): #|| health == 0:
            regenerating_health = false
            $HealthRegen.stop()

    if gb_Utils.is_bit_enabled(status_settings, 1):
        if endurance < get_max_endurance() && !regenerating_endurance:
            regenerating_endurance = true
            $EnduranceRegen.start()
        elif endurance >= get_max_endurance():
            regenerating_endurance = false
            $EnduranceRegen.stop()

    var max_h = get_max_health()
    var max_e = get_max_endurance()

    if _max_health_cache != max_h:
        var hperc = (health / _max_health_cache)
        health = clamp(max_h*hperc, 0, max_h)
        _max_health_cache = max_h

    if _max_endurance_cache != max_e:
        var eperc = (endurance / _max_endurance_cache)
        endurance = clamp(max_e*eperc, 0, max_e)
        _max_endurance_cache = max_e