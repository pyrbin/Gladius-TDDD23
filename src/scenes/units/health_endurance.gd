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

func _ready():
    set_process(true)
    $EnduranceRegen.connect("timeout", self, "_on_regen_endurance")

func damage(amount):
    health = clamp(health-amount, 0, max_health)
    if health == 0:
        emit_signal("on_health_zero")

func heal(amount):
    var hp = health
    health = clamp(health+amount, 0, max_health)
    if hp == 0 && health > 0:
        emit_signal("on_revive")

func mod_endurance(amount):
    endurance = clamp(endurance+amount, 0, max_endurance)

func _on_regen_endurance():
    mod_endurance(endurance_regen)

func _process(d):
    if endurance < max_endurance && !regenerating_endurance:
        regenerating_endurance = true
        $EnduranceRegen.start()
    elif endurance >= max_endurance:
        regenerating_endurance = false
        $EnduranceRegen.stop()
        