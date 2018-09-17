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
signal curr_health_zero

enum ATTR {
	HEALTH
	ENDURANCE
	MAX_HEALTH
	MAX_ENDURANCE
	ATK_SPEED
	POWER
	MOV_SPEED
	CRIT
}

enum MODIFIER { PERCENT, VALUE }

# Start values
export (int) var max_health = 100
export (int) var max_endurance = 100
export (int) var health = 100
export (int) var endurance = 100
export (int) var power = 0
export (int) var attack_speed = 1
export (int) var movement_speed = 1
export (int) var crit_chance = 0

onready var attributes = {
	ATTR.MAX_HEALTH: 0,
	ATTR.MAX_ENDURANCE: 0,
	ATTR.HEALTH: 0,
	ATTR.ENDURANCE: 0,
	ATTR.POWER : 0,
	ATTR.ATK_SPEED : 0,
	ATTR.MOV_SPEED : 0,
	ATTR.CRIT : 0
}
onready var mod_percent = {}
onready var mod_value= {}

func _ready():
	mod_percent = gb_Utils.deep_copy(attributes)
	for p in mod_percent:
		mod_percent[p] = 1
	mod_value = gb_Utils.deep_copy(attributes)
	attributes[ATTR.MAX_HEALTH] = max_health
	attributes[ATTR.MAX_ENDURANCE] = max_endurance
	attributes[ATTR.HEALTH] = clamp(health, 0, max_health)
	attributes[ATTR.ENDURANCE] = clamp(endurance, 0, max_endurance)
	attributes[ATTR.POWER] = power
	attributes[ATTR.ATK_SPEED] = attack_speed
	attributes[ATTR.MOV_SPEED] = movement_speed
	attributes[ATTR.CRIT] = crit_chance

func final_stat(stat_key):
	var value = attributes[stat_key] * mod_percent[stat_key] + mod_value[stat_key]
	if stat_key == ATTR.HEALTH:
		return clamp(value, 0, final_stat(ATTR.MAX_HEALTH))
	if stat_key == ATTR.ENDURANCE:
		return clamp(value, 0, final_stat(ATTR.MAX_ENDURANCE))
	return value

func get_modifier(stat, mod):
	match mod:
		MODIFIER.PERCENT:
			return mod_percent[stat]
		MODIFIER.VALUE:
			return mod_value[stat]

func set_modifier(set_stat, value, mod):
	match mod:
		MODIFIER.PERCENT:
			mod_percent[set_stat] = value
		MODIFIER.VALUE:
			mod_value[set_stat] = value
	if final_stat(ATTR.HEALTH) == 0:
		emit_signal("curr_health_zero")

func attr_to_str(stat_key):
	match stat_key:
		ATTR.MAX_HEALTH: return "MAX_HEALTH"
		ATTR.MAX_ENDURANCE: return "MAX_ENDURANCE"
		ATTR.HEALTH: return "HEALTH"
		ATTR.ENDURANCE: return "ENDURANCE"
		ATTR.POWER : return "POWER"
		ATTR.ATK_SPEED : return "ATK_SPEED"
		ATTR.MOV_SPEED : return "MOV_SPEED"
		ATTR.CRIT : return "CRIT"

func str_to_attr(stat):
	match stat:
		"MAX_HEALTH" : return ATTR.MAX_HEALTH
		"MAX_ENDURANCE" : return ATTR.MAX_ENDURANCE
		"HEALTH" : return ATTR.HEALTH
		"ENDURANCE" : return ATTR.ENDURANCE
		"POWER" : return ATTR.POWER
		"ATK_SPEED" : return ATTR.ATK_SPEED
		"MOV_SPEED" : return ATTR.MOV_SPEED
		"CRIT" : return ATTR.CRIT
