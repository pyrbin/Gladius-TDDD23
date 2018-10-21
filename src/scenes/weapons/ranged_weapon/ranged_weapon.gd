extends "../weapon.gd"

export (AudioStream) var sfx_fire;

onready var projectile = preload("Projectile.tscn")
onready var projectile_pivot = $Pivot/Area2D/Sprite/Projectile_Pivot
onready var root_projs = get_tree().get_nodes_in_group("Root_Projs")[0]
onready var rc_mid = $Pivot/Raycasts/RC_Mid
onready var rc_top = $Pivot/Raycasts/RC_Top
onready var rc_bot = $Pivot/Raycasts/RC_Bot

var _current_proj = null

func _ready():
    wep_sprite.set_flip_v(false)
    hitbox.disabled = true
    knockback_force = 100
    
func see_target(target):
    if rc_mid.is_colliding() && rc_top.is_colliding() && rc_bot.is_colliding():
        return rc_mid.get_collider().owner == target && rc_top.get_collider().owner == target && rc_bot.get_collider().owner == target
    return false

func _ammo_loaded():
    return projectile_pivot.get_child_count() > 0

func _setup():
    rc_mid.cast_to = Vector2(0, hit_range)
    rc_bot.cast_to = Vector2(0, hit_range)
    rc_top.cast_to = Vector2(0, hit_range)
    if not _ammo_loaded():
        _reload()

func _reload():
    if _ammo_loaded(): return
    _current_proj = null
    _current_proj = projectile.instance()
    _current_proj.connect("on_collision", self, "_on_projectile_hit")
    _current_proj.connect("missed", self, "_on_projectile_missed")
    projectile_pivot.add_child(_current_proj)
    _current_proj.sprite.set_texture(load(data.ammo))

func _on_projectile_hit(co, projectile):
    if _current_proj == null: return;
    if is_hitable(co):
        _on_body_entered(co, projectile.combo)
    projectile.stop()
    projectile = null

func _on_projectile_missed():
    #reset_combo()
    pass
    
func _fire_ammo(combo=true):
    if _current_proj == null: return;
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
    _current_proj.fire(weapon_attack_speed, combo)

func is_ready():
    return .is_ready() && _ammo_loaded()

func apply_slow():
    if holder.get("stats"):
        holder.stats.add_effect_fac("Ranged Reload", STAT.MOVEMENT, -65, STAT.PERCENT, cooldown_timer.wait_time)

func _action_attack():
    utils.play_sound(sfx_fire, wep_sfx_pl)
    apply_slow()
    _fire_ammo()
    _clear_attack(false)

func _action_ult_attack():
    apply_slow()
    reset_combo()
    _fire_ammo(false)
    _reload()
    yield(utils.timer(0.25), "timeout")
    _fire_ammo(false)
    _clear_attack(false)

func _on_cooldown_finished():
    _reload()

func _on_animation_finished(anim):
    _clear_attack(false)
    