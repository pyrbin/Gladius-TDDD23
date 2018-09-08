extends "res://scenes/common/state.gd"

var speed = 0.0
var velocity = Vector2()

func update(delta):
    var body_sprite = owner.get_node("BodyPivot/Body")
    var shadow_sprite = owner.get_node("Shadow")
    var status = owner.look_state == owner.BOTTOM_LEFT or owner.look_state == owner.TOP_LEFT
    body_sprite.set_flip_h(status)
    shadow_sprite.set_flip_h(status)