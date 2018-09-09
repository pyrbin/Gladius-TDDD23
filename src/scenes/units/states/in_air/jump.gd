extends "../motion.gd"

export (int) var MAX_JUMP_DISTANCE = 1000
onready var tween = get_node("Tween")

func enter():
    owner.connect("unit_collided", self, "_on_unit_collision")
    var direction = owner.get_movement_direction().normalized()
    var distance = MAX_JUMP_DISTANCE
    tween.interpolate_property(owner, "position",
                    owner.position, owner.position + direction * distance, 0.4,
                    Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    owner.get_node("AnimationPlayer").stop()
    owner.get_node("AnimationPlayer").play("jump")
    owner.get_node("Collision").disabled = true;
    tween.start()

func _on_animation_finished(anim_name):
    owner.get_node("Collision").disabled = false;
    emit_signal("finished", "idle")

func _on_unit_collision(collider):
    tween.stop_all()
    tween.remove_all()