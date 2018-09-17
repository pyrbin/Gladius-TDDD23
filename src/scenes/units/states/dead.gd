extends "res://scenes/common/state.gd"

func enter():
    owner.get_node("AnimationPlayer").stop()
    owner.hide()
    owner.get_node("Collision").disabled = true

func _physics_process():
    if !owner.dead:
        owner.show()
        owner.get_node("Collision").disabled = false