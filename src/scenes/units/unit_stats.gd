extends Node

"""
	Attributes:
	=======================

		Health, CurrHealth, MaxHealth
		Endurance, CurrEndurande, MaxEndurance

		Power  	  - weapon damage
		Atk speed - weapon attackspeed
		Mov Speed     - movement speed
		Crit      - crit chance (1.5x)
"""
signal on_health_zero
signal on_revive

enum ATTR {
	HEALTH
	ENDURANCE
	ATK_SPEED
	POWER
	MOV_SPEED
	CRIT
}

enum MODIFIER { PERCENT, VALUE }

# Start values
export (float) var health = 100
export (float) var endurance = 100
export (float) var power = 0
export (float) var attack_speed = 1
export (float) var movement_speed = 1
export (float) var crit_chance = 0

onready var attributes = {
	ATTR.HEALTH: 0.0,
	ATTR.ENDURANCE: 0.0,
	ATTR.POWER : 0.0,
	ATTR.ATK_SPEED : 0.0,
	ATTR.MOV_SPEED : 0.0,
	ATTR.CRIT : 0.0
}
onready var mod_total = {}
onready var mod_percent = {}
onready var mod_value= {}

var regenerating_endurance = false
func _ready():
	set_process(true)
	$EnduranceRegen.connect("timeout", self, "_on_regen_endurance")
	mod_percent = gb_Utils.deep_copy(attributes)
	for p in mod_percent:
		mod_percent[p] = 1
	mod_value = gb_Utils.deep_copy(attributes)
	attributes[ATTR.HEALTH] = clamp(health, 0, health)
	attributes[ATTR.ENDURANCE] = clamp(endurance, 0, endurance)
	attributes[ATTR.POWER] = power
	attributes[ATTR.ATK_SPEED] = attack_speed
	attributes[ATTR.MOV_SPEED] = movement_speed
	attributes[ATTR.CRIT] = crit_chance

func _on_regen_endurance():
	mod_modifier("ENDURANCE", 3, "VALUE")

func _process(d):
	if final_stat("ENDURANCE") < get_attribute("ENDURANCE") && !regenerating_endurance:
		regenerating_endurance = true
		$EnduranceRegen.start()
	elif final_stat("ENDURANCE") >= get_attribute("ENDURANCE"):
		regenerating_endurance = false
		$EnduranceRegen.stop()

# TODO: combine all modifications to a single dict for easier management
func final_stat(stat_key):
	if typeof(stat_key) == TYPE_STRING: 
		stat_key = str_to_attr(stat_key)
	var value = (attributes[stat_key] * mod_percent[stat_key]) + mod_value[stat_key]
	if stat_key == ATTR.HEALTH:
		return clamp(value, 0, attributes[stat_key])
	if stat_key == ATTR.ENDURANCE:
		return clamp(value, 0, attributes[stat_key])
	return value

func get_attribute(stat):
	if typeof(stat) == TYPE_STRING: 
		stat = str_to_attr(stat)
	return attributes[stat]

func get_modifier(stat, mod):
	if typeof(mod) == TYPE_STRING: 
		mod = str_to_mod(mod)
	if typeof(stat) == TYPE_STRING: 
		stat = str_to_attr(stat)
	match mod:
		MODIFIER.PERCENT:
			return mod_percent[stat]
		MODIFIER.VALUE:
			return mod_value[stat]

func mod_modifier(set_stat, value, mod):
	if typeof(mod) == TYPE_STRING: 
		mod = str_to_mod(mod)
	if typeof(set_stat) == TYPE_STRING: 
		set_stat = str_to_attr(set_stat)
	var last_val = null
	match mod:
		MODIFIER.PERCENT:
			last_val = mod_percent[set_stat]
		MODIFIER.VALUE:
			last_val = mod_value[set_stat]
	var final_value = last_val + value
	set_modifier(set_stat, final_value, mod)

func set_modifier(set_stat, value, mod):
	if typeof(mod) == TYPE_STRING: 
		mod = str_to_mod(mod)
	if typeof(set_stat) == TYPE_STRING: 
		set_stat = str_to_attr(set_stat)
	var hp = final_stat(ATTR.HEALTH)
	match mod:
		MODIFIER.PERCENT:
			mod_percent[set_stat] = value
		MODIFIER.VALUE:
			mod_value[set_stat] = value
	if hp == 0 && final_stat(ATTR.HEALTH) > 0:
		emit_signal("on_revive")
	elif final_stat(ATTR.HEALTH) == 0:
		emit_signal("on_health_zero")

func attr_to_str(stat_key):
	match stat_key:
		ATTR.HEALTH: return "HEALTH"
		ATTR.ENDURANCE: return "ENDURANCE"
		ATTR.POWER : return "POWER"
		ATTR.ATK_SPEED : return "ATK_SPEED"
		ATTR.MOV_SPEED : return "MOV_SPEED"
		ATTR.CRIT : return "CRIT"

func str_to_attr(stat):
	match stat:
		"HEALTH" : return ATTR.HEALTH
		"ENDURANCE" : return ATTR.ENDURANCE
		"POWER" : return ATTR.POWER
		"ATK_SPEED" : return ATTR.ATK_SPEED
		"MOV_SPEED" : return ATTR.MOV_SPEED
		"CRIT" : return ATTR.CRIT

func str_to_mod(mod):
	match mod:
		"PERCENT" : return MODIFIER.PERCENT
		"VALUE" : return MODIFIER.VALUE