extends "on_ground.gd"

func enter():
    owner.get_node("AnimationPlayer").queue("idle")
    if owner.get_movement_direction():
        emit_signal("finished", "move")
        
func handle_input(event):
    return .handle_input(event)

func update(delta):
    if owner.get_node("AnimationPlayer").current_animation != "idle":
        owner.get_node("AnimationPlayer").get_animation("move").loop = false
        owner.get_node("AnimationPlayer").queue("idle")
    if owner.get_movement_direction():
        emit_signal("finished", "move")
    return .update(delta)
