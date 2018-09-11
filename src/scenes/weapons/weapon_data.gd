extends Node

enum WEAPON_TYPE { SWING, STAB, RANGED }

export (String) var identifier = ""
export (WEAPON_TYPE) var type = SWING
export (float) var damage = 0
export (float) var speed = 0
export (float) var cooldown = 0

func _ready():
	pass
