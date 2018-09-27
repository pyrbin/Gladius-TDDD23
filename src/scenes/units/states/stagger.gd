extends "res://scenes/common/state.gd"

var reviving = false

func enter():
    var stagger_anim = owner.get_node("AnimationPlayer").get_animation("stagger")
    stagger_anim.track_set_key_value(0, 1, owner.skin_color)
    owner.get_node("AnimationPlayer").play("stagger")
    reviving = false
    owner.iframe = true

func _on_animation_finished(anim_name):
    if anim_name == "stagger":
        owner.reset_modulate()
        reviving = true
        owner.iframe = false
        emit_signal("finished", "idle")    