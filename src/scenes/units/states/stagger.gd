extends "res://scenes/common/state.gd"

var reviving = false

func enter():
    var body_color = owner.body.modulate
    var stagger_anim = owner.get_node("AnimationPlayer").get_animation("stagger")
    for i in range(0, 3):
        stagger_anim.track_set_key_value(i, 1, body_color)
    owner.get_node("AnimationPlayer").play("stagger")
    owner.get_node("Collision").disabled = true
    reviving = false

func _on_animation_finished(anim_name):
    if anim_name == "stagger":
        owner.get_node("Collision").disabled = false
        emit_signal("finished", "idle")