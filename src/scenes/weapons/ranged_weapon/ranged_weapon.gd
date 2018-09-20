extends "../weapon.gd"

onready var projectile = preload("Projectile.tscn")

func _ready():
    wep_sprite.set_flip_v(false)

func _action_attack():
    print("doing it")
    var pos = holder.get_aim_position()
    var angle = holder.global_position.angle_to_point(pos)
    var dir = Vector2(-cos(angle), -sin(angle))
    var proj = projectile.instance()
    get_tree().get_nodes_in_group("Root_Projs")[0].add_child(proj)
    proj.position = holder.global_position
    proj.direction = dir
    proj.look_at(pos)
    _current_hit_targets.clear()
    _target = null
    _attack_state = IDLE