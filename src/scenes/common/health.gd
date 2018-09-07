extends Node

export (int) var health = 1
export (int) var maxHealth = 1
export (int) var minHealth = 0

var dead = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func modify(amount):
	health = clamp(health+amount, minHealth, maxHealth)	
	if (health == minHealth):
		dead = true