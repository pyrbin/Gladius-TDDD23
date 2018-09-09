extends "on_ground.gd"

export (float) var MAX_WALK_SPEED = 450
export (float) var MAX_SPRINT_SPEED = 700

var sprinting = false

func enter():
    speed = 0.0
    var anim_player = owner.get_node("AnimationPlayer")
    anim_player.get_animation("move").loop = true
    anim_player.play("move")

func handle_input(event):
    sprinting = (event.is_action_pressed("sprint"))
    return .handle_input(event)

func update(delta):
    var movement_direction = owner.get_movement_direction()

    if not movement_direction:
        var anim_player = owner.get_node("AnimationPlayer")
        anim_player.get_animation("move").loop = false
        emit_signal("finished", "idle")
        
    speed = MAX_SPRINT_SPEED if sprinting else MAX_WALK_SPEED
    move(speed, movement_direction, delta)
    return .update(delta)

func move(speed, direction, delta):
    direction = direction.normalized()
    speed = speed / sqrt(2) if direction.length() < 1 else speed
    velocity = direction * speed
    owner.velocity = velocity
