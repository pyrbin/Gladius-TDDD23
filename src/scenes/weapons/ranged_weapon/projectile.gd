extends Area2D
signal on_collision(co, projectile)
signal missed

const PROJECTILE_DESPAWN_DELAY = 2000
const HITABLE_GROUP_NAME = "Hitable"

onready var root_projs = get_tree().get_nodes_in_group("Root_Projs")[0]
onready var collision = $CollisionShape2D
onready var sprite = $Sprite
onready var timer = $Timer

var direction = Vector2()
var fly = false
var force = 600
var combo = true

func _ready():
    collision.disabled=true
    timer.connect("timeout", self, "_on_timer_finished")

func fire(p_force, p_combo=true):
    timer.start()
    collision.disabled=false
    fly = true
    force = p_force
    combo = p_combo

func stop(missed=false):
    if missed && combo:
        emit_signal("missed")
    fly = false
    queue_free()
    
func _physics_process(d):
    if fly:
        position += direction * force * d

func _on_timer_finished():
    stop(true)

func _on_Projectile_body_entered(body):
    return
    stop(true)
    
func _on_Projectile_area_entered(area):
    if not fly: return
    var body = area.owner
    if body == owner: return
    if not body.is_in_group(HITABLE_GROUP_NAME) || body.iframe: return
    #   if body.has_method("add_to_body"):
    #       root_projs.remove_child(self)
    #       body.add_to_body(self)
    collision.disabled=true
    emit_signal("on_collision", body, self)