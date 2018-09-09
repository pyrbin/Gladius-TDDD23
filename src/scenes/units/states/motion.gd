extends "res://scenes/common/state.gd"

var speed = 0.0
var velocity = Vector2()

const WEAPON_DRAW_LAYER = 7
const WEAPON_DRAW_LAYER_TOP_OFFSET = -5

func update(delta):
    var sprite_player = owner.get_node("SpritePlayer")
    var wep_pivots = owner.get_node("BodyPivot/WeaponPivot")

    if owner.look_state == owner.TOP_LEFT:
        sprite_player.play("Top_Left")
        wep_pivots.z_index = WEAPON_DRAW_LAYER + WEAPON_DRAW_LAYER_TOP_OFFSET

    elif owner.look_state == owner.TOP_RIGHT:
        sprite_player.play("Top_Right")
        wep_pivots.z_index = WEAPON_DRAW_LAYER + WEAPON_DRAW_LAYER_TOP_OFFSET

    elif owner.look_state == owner.BOTTOM_LEFT:
        sprite_player.play("Bottom_Left")
        wep_pivots.z_index = WEAPON_DRAW_LAYER

    elif owner.look_state == owner.BOTTOM_RIGHT:
        sprite_player.play("Bottom_Right")
        wep_pivots.z_index = WEAPON_DRAW_LAYER