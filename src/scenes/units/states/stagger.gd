extends "res://scenes/common/state.gd"

var reviving = false

func enter():
    print("STAGGER")
    var stagger_anim = owner.get_node("AnimationPlayer").get_animation("stagger")
    stagger_anim.track_set_key_value(0, 1, owner.skin_color)
    owner.get_node("AnimationPlayer").play("stagger")
    owner.iframe = true
    reviving = false

func _on_animation_finished(anim_name):
    if anim_name == "stagger":
        print("over")
        owner.body.modulate = owner.skin_color
        reviving = true
        owner.iframe = false
        emit_signal("finished", "idle")    