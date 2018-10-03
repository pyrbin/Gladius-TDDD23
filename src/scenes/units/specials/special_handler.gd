extends Node

signal cooldown_over

onready var cooldown = $Cooldown

const Effect = preload("res://scenes/units/stat_system/effect.gd")

func _ready():
	cooldown.connect("timeout", self, "_on_cooldown_over")

func use(special):
	if not cooldown.is_stopped(): return
	cooldown.wait_time = special.cooldown
	if special.effects.size() > 0:
		use_consumable(special)
	cooldown.start()

func use_consumable(consumable):
	for efx in consumable.effects:
		var data = consumable.effects[efx]
		var effect = Effect.new(efx, owner, data["MODIFIERS"], data["DURATION"], data["INTERVAL"])
		owner.stats.add_effect(effect)
		print(effect.identifier)

func _process(delta):
	pass

func _on_cooldown_over():
	pass