extends "../motion.gd"

export (int) var JUMP_FORCE = 800
onready var tween = get_node("Tween")
var jump_force = Vector2()

func _ready():
    owner.connect("unit_collided", self, "_on_unit_collision")

func enter():
    var direction = owner.get_movement_direction().normalized()
    jump_force = Vector2(JUMP_FORCE, JUMP_FORCE) * direction
    tween.interpolate_property(self, "jump_force", jump_force, Vector2(), 0.6,
                    Tween.TRANS_LINEAR, Tween.EASE_IN)
    owner.get_node("AnimationPlayer").stop()
    owner.get_node("AnimationPlayer").play("jump")
    tween.start()

func update(d):
    owner.velocity = jump_force

func _on_animation_finished(anim_name):
    if anim_name == "jump":
        emit_signal("finished", "idle")

func _on_unit_collision(collider):
    tween.stop_all()
    tween.remove_all()