extends Node

signal attribute_changed(attr_type)

enum {
	VITALITY,
	ATK_SPEED,
	POWER,
	MOV_SPEED,
	CRIT
}

enum MOD { 
	PERCENT, 
	VALUE 
}

# Start values
export (float) var power = 0
export (float) var vitality = 0
export (float) var attack_speed = 0
export (float) var movement_speed = 0
export (float) var crit_chance = 0

onready var attributes = {
	POWER : 0.0,
	VITALITY: 0.0,
	ATK_SPEED : 0.0,
	MOV_SPEED : 0.0,
	CRIT : 0.0
}

onready var mod_percent = {}
onready var mod_value= {}

func _ready():
	set_process(true)
	mod_percent = gb_Utils.deep_copy(attributes)
	mod_value = gb_Utils.deep_copy(attributes)
	attributes[POWER] = power
	attributes[VITALITY] = vitality
	attributes[ATK_SPEED] = attack_speed
	attributes[MOV_SPEED] = movement_speed
	attributes[CRIT] = crit_chance

# TODO: combine all modifications to a single dict for easier management
func final_stat(stat_key):
	if typeof(stat_key) == TYPE_STRING: 
		stat_key = str_to_attr(stat_key)
	var perc =  mod_percent[stat_key]
	var value = (attributes[stat_key] + mod_value[stat_key])
	value *= 1 + (perc/100)
	return round(value)

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
		MOD.PERCENT:
			return mod_percent[stat]
		MOD.VALUE:
			return mod_value[stat]

func mod_modifier(set_stat, value, mod):
	if typeof(mod) == TYPE_STRING: 
		mod = str_to_mod(mod)
	if typeof(set_stat) == TYPE_STRING: 
		set_stat = str_to_attr(set_stat)
	var last_val = null
	match mod:
		MOD.PERCENT:
			last_val = mod_percent[set_stat]
		MOD.VALUE:
			last_val = mod_value[set_stat]
	var final_value = last_val + value
	set_modifier(set_stat, final_value, mod)

func set_modifier(set_stat, value, mod):
	if typeof(mod) == TYPE_STRING: 
		mod = str_to_mod(mod)
	if typeof(set_stat) == TYPE_STRING: 
		set_stat = str_to_attr(set_stat)
	match mod:
		MOD.PERCENT:
			mod_percent[set_stat] = value
		MOD.VALUE:
			mod_value[set_stat] = value
	if set_stat == VITALITY:
		owner.status.apply_health_bonus(final_stat(VITALITY))
	emit_signal("attribute_changed", set_stat)		

func attr_to_str(stat_key):
	match stat_key:
		POWER : return "POWER"
		VITALITY : return "VITALITY"
		ATK_SPEED : return "ATK_SPEED"
		MOV_SPEED : return "MOV_SPEED"
		CRIT : return "CRIT"

func str_to_attr(stat):
	match stat:
		"POWER" : return POWER
		"VITALITY" : return VITALITY
		"ATK_SPEED" : return ATK_SPEED
		"MOV_SPEED" : return MOV_SPEED
		"CRIT" : return CRIT

func str_to_mod(mod):
	match mod:
		"PERCENT" : return MOD.PERCENT
		"VALUE" : return MOD.VALUE