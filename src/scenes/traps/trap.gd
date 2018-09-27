extends Area2D

onready var anim_player = $AnimationPlayer

const Effect = preload("res://scenes/units/stat_system/effect.gd")
const Modifier = preload("res://data/modifier.gd")

var activated = false
var _targets = []

func _process(delta):
    if not activated: return
    for t in _targets:
        trigger(t)

func trigger(unit):
	pass

func _on_Trap_body_entered(body):
    _targets.append(body)

func _on_Trap_body_exited(body):
    if _targets.has(body):
        _targets.remove(_targets.find(body))
