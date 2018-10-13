extends "res://scenes/weapons/ranged_weapon/ranged_weapon.gd"

enum {
    UP, 
    DOWN
}

var swing_state = UP


func _action_attack():
    apply_slow()
    utils.play_sound(sfx_fire, wep_sfx_pl)
    _swing_sling()

func _action_ult_attack():
    apply_slow()
    _knockback_air_mod = 3
    _knockback_mod = 2
    _action_attack()
    
func _swing_sling():
    if _current_proj == null: return;
    if swing_state == UP:
        anim_player.play("swing_up")
        swing_state = DOWN
    elif swing_state == DOWN:
        swing_state = UP
        anim_player.play("swing_down")

func fire_sling():
    _fire_ammo()

func _on_animation_finished(anim):
    _clear_attack(false)