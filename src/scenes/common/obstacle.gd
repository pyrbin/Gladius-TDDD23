extends KinematicBody2D

export (AudioStream) var sfx_onhit = null
export (AudioStream) var sfx_destroy = null
export (bool) var destroy_on_combo = false

var dead = false

func _ready():
    set_dead(dead) 

func damage(amount, actor, unblockable=false, soft_attack=false, crit=false):
    var action = gb_CombatText.HitInfo.ACTION.HEAL if amount <= 0 else gb_CombatText.HitInfo.ACTION.DAMAGE
    var type = gb_CombatText.HitInfo.TYPE.NORMAL if not crit else gb_CombatText.HitInfo.TYPE.CRIT
    var hit_info = gb_CombatText.HitInfo.new(amount, actor, self, type, action)
    gb_CombatText.popup(hit_info, global_position)
    if destroy_on_combo && crit:
        set_dead(true)
    return true
    
func has_iframe():
    return false

func on_hit(player):
    if not dead:
        utils.play_sound(sfx_onhit, player)
    else:
        utils.play_sound(sfx_destroy, player)

func set_dead(value):
    dead = value
    if dead:
        $AnimPlayer.play("dead")
    $CollisionShape2D.disabled = value;
    $Pivot/Area2D/CollisionShape2D.disabled = value;
    set_process(not value)
    set_physics_process(not value)