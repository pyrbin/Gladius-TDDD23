extends Node

signal duration_over
signal cooldown_over

onready var cooldown = $Cooldown
onready var duration = $Duration

func _ready():
	cooldown.connect("timeout", self, "_on_cooldown_over")
	duration.connect("timeout", self, "_on_duration_over")

func use(consumable):
	for attr_key in consumable.attributes:
		if not ["VITALITY", "POWER", "ATK_SPEED", "MOV_SPEED", "CRIT", "HEALTH", "ENDURANCE"].has(attr_key): 
			continue
		var attr = consumable.attributes[attr_key]
		for mod_key in attr:
			var val = attr[mod_key]
			if "HEALTH" == (attr_key):
				var val_hp = val if mod_key == "VALUE" else status.get_max_health() * (val/100)
				owner.status.heal(val_hp)
			if "ENDURANCE" == (attr_key):
				var val_end = val if mod_key == "VALUE" else status.max_endurance() * (val/100)
				owner.status.mod_endurance(val_end)
	cooldown.

func _process(delta):
	pass

func _on_duration_over():
	pass

func _on_cooldown_over():
	pass