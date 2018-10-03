extends "res://scenes/weapons/ranged_weapon/ranged_weapon.gd"

enum SWING_STATE {UP, DOWN}

var swing_state = UP

func _fire_ammo():
    if _current_proj == null: return;
    if swing_state == UP:
        anim_player.play("swing_up")
        swing_state = DOWN
    elif swing_state == DOWN:
        swing_state = UP
        anim_player.play("swing_down")

func fire_sling():
    var pos = holder.get_aim_position()
    var angle = _current_proj.global_position.angle_to_point(pos)
    var dir = Vector2(-cos(angle), -sin(angle))
    var proj_pos = _current_proj.get_node("Sprite").global_position
    projectile_pivot.remove_child(_current_proj)
    root_projs.add_child(_current_proj)
    _current_proj.collision_mask = $Pivot/Area2D.collision_mask
    _current_proj.position = proj_pos
    _current_proj.direction = dir
    _current_proj.look_at(pos)
    _current_proj.fire(data.attack_speed)
