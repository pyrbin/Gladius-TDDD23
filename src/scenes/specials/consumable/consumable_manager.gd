extends Node

onready 



func _ready():
	pass

func use(consumable, ):
	for attr_key in cons.attributes:
		if not ["VITALITY", "POWER", "ATK_SPEED", "MOV_SPEED", "CRIT", "HEALTH", "ENDURANCE"].has(attr_key): 
			continue
		var attr = cons.attributes[attr_key]
		for mod_key in attr:
			var val = attr[mod_key]
			if "HEALTH" == (attr_key):
				var val_hp = val if mod_key == "VALUE" else status.get_max_health() * (val/100)
				status.heal(val_hp)
			if "ENDURANCE" == (attr_key):
				var val_end = val if mod_key == "VALUE" else status.max_endurance() * (val/100)
				status.mod_endurance(val_end)

func _process(delta):
	pass
