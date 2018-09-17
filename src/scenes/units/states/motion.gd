extends "res://scenes/common/state.gd"

var speed = 0.0
var velocity = Vector2()


func _physics_process(delta):
    if owner.dead:
        emit_signal("finished", "dead")
