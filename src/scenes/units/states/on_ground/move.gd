extends "on_ground.gd"
var anim_player
func enter():
    speed = 0.0
    anim_player = owner.get_node("AnimationPlayer")
    anim_player.get_animation("move").loop = true
    anim_player.play("move")

func handle_input(event):
    return .handle_input(event)

func update(delta):
    var movement_direction = owner.get_movement_direction()
    move(owner.stats.get_stat(STAT.MOVEMENT), movement_direction, delta)
    if owner.velocity == Vector2():
        var anim_player = owner.get_node("AnimationPlayer")
        anim_player.get_animation("move").loop = false
        emit_signal("finished", "idle")
    elif not anim_player.is_playing():
        anim_player.get_animation("move").loop = true
        anim_player.play("move")
    return .update(delta)

func move(speed, direction, delta):
    if not direction: return
    direction = direction.normalized()
    speed = speed / sqrt(2) if direction.length() < 1 else speed
    velocity = direction * speed
    owner.velocity = velocity

