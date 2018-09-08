extends "res://scenes/common/state.gd"

var speed = 0.0
var velocity = Vector2()

func update(delta):
    var body_sprite = owner.get_node("BodyPivot/Body")
    var shadow_sprite = owner.get_node("Shadow")
    var sprite_player = owner.get_node("SpritePlayer")
    var wep_pivots = owner.get_node("WeaponPivots")

    if (owner.look_state == owner.TOP_LEFT or owner.look_state == owner.TOP_RIGHT):
        sprite_player.play("Top")
        wep_pivots.z_index = -2
    else:
        sprite_player.play("Bottom")
        wep_pivots.z_index = 2

    var flip_flag = owner.look_state == owner.BOTTOM_LEFT or owner.look_state == owner.TOP_LEFT
    body_sprite.set_flip_h(flip_flag)
    shadow_sprite.set_flip_h(flip_flag)