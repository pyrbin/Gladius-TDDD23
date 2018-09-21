extends Area2D
signal on_collision(co, projectile)

const PROJECTILE_DESPAWN_DELAY = 2000

onready var root_projs = get_tree().get_nodes_in_group("Root_Projs")[0]
onready var collision = $CollisionShape2D
onready var sprite = $Sprite
onready var timer = $Timer

var direction = Vector2()
var fly = false
var force = 600

func _ready():
    collision.disabled=true
    timer.connect("timeout", self, "_on_timer_finished")

func fire(p_force):
    timer.start()
    collision.disabled=false
    fly = true
    force = p_force

func stop():
    fly = false
#   yield(get_tree().create_timer(PROJECTILE_DESPAWN_DELAY/1000.0), 'timeout')
    queue_free()
    
func _physics_process(d):
    if fly:
        position += direction * force * d

func _on_timer_finished():
    if not fly: return
    fly = false
    queue_free()

func _on_Projectile_body_entered(body):
    if not fly: return
    if body == owner: return
#   if body.has_method("add_to_body"):
#       root_projs.remove_child(self)
#       body.add_to_body(self)
    collision.disabled=true
    emit_signal("on_collision", body, self)
