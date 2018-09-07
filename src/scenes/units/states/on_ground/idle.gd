extends "on_ground.gd"

func enter():
    owner.get_node("AnimationPlayer").queue("idle")

func handle_input(event):
    return .handle_input(event)

func update(delta):
    if owner.get_movement_direction():
        emit_signal("finished", "move")
    return .update(delta)
