extends "res://scenes/common/state.gd"

func enter():
    var stagger_anim = owner.get_node("AnimationPlayer").get_animation("stagger")
    #stagger_anim.track_set_key_value(0, 1, owner.skin_color)
    owner.get_node("AnimationPlayer").playback_speed = 1/owner.stagger_time
    owner.get_node("AnimationPlayer").play("stagger")
    owner.iframe = true

func _on_animation_finished(anim_name):
    if anim_name == "stagger":
        owner.get_node("Visuals/Pivot").material = null
        owner.iframe = false
        owner.get_node("AnimationPlayer").playback_speed = 1
        emit_signal("finished", "idle")    