extends "res://scenes/common/state.gd"

var reviving = false

func enter():
    owner.get_node("AnimationPlayer").play("death")
    owner.get_node("Collision").disabled = true
    reviving = false

func handle_input(event):
    var rmb = event.is_action_pressed("right_attack")
    if rmb && owner && owner.stats:
        owner.stats.set_modifier("HEALTH", 1, "PERCENT")
    return .handle_input(event)

func update(delta):
    if !owner.dead && not reviving:
        reviving = true
        owner.get_node("Collision").disabled = false
        owner.get_node("AnimationPlayer").play("revive")
    return .update(delta)

func _on_animation_finished(anim_name):
    if anim_name == "revive":
        emit_signal("finished", "idle")