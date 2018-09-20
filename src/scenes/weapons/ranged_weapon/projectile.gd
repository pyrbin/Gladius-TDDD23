extends Area2D

signal on_collision(co)

const FORCE = 600
var direction = Vector2()

func _physics_process(d):
	position += direction * FORCE * d

func _on_Projectile_body_entered(body):
	print(body)
	if body == owner: return
	emit_signal("on_collision", body)
	#queue_free()
