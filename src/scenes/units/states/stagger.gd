extends "res://scenes/common/state.gd"

var reviving = false

func enter():
    var stagger_anim = owner.get_node("AnimationPlayer").get_animation("stagger")
    stagger_anim.track_set_key_value(0, 1, owner.skin_color)
    owner.get_node("AnimationPlayer").play("stagger")
    owner.iframe = true
    reviving = false

func _on_animation_finished(anim_name):
    if anim_name == "stagger":
        owner.get_node("Visuals/Pivot/Container").modulate = Color(1,1,1,1)
        owner.get_node("Visuals/Pivot/WeaponPivot").modulate = Color(1,1,1,1)
        owner.get_node("Visuals/Pivot/L_Hand_Pivot").modulate = Color(1,1,1,1)
        owner.get_node("Visuals/Pivot/U_Hand_Pivot").modulate = Color(1,1,1,1)
        reviving = true
        owner.iframe = false
        emit_signal("finished", "idle")    