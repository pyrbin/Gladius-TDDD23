extends Node

signal on_health_zero
signal on_revive

enum {
    HEALTH
    ENDURANCE
}

# Start values
export (float) var health = 100.0
export (float) var endurance = 100.0
export (float) var max_health = 100.0
export (float) var max_endurance = 100.0
export (float) var endurance_regen = 3.0

var regenerating_endurance = false
var _health_bonus = 0 

func apply_health_bonus(bonus):
    var perc = health / get_max_health()
    _health_bonus = bonus
    health = round(perc * get_max_health())

func get_max_health():
    return round(max_health + _health_bonus)

func _ready():
    set_process(true)
    $EnduranceRegen.connect("timeout", self, "_on_regen_endurance")

func damage(amount):
    health = round(clamp(health-amount, 0, get_max_health()))
    if health == 0:
        emit_signal("on_health_zero")

func heal(amount):
    var hp = health
    health = round(clamp(health+amount, 0, get_max_health()))
    if hp == 0 && health > 0:
        emit_signal("on_revive")

func mod_endurance(amount):
    endurance = round(clamp(endurance+amount, 0, max_endurance))

func _on_regen_endurance():
    mod_endurance(endurance_regen)

func _process(d):
    if endurance < max_endurance && !regenerating_endurance:
        regenerating_endurance = true
        $EnduranceRegen.start()
    elif endurance >= max_endurance:
        regenerating_endurance = false
        $EnduranceRegen.stop()
        