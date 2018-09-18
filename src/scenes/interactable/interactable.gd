extends Area2D

onready var anim_player = $AnimationPlayer
onready var sprite = $Visuals/Pivot/Sprite
onready var player = null
onready var outline_color = Color(0,0,0,0)

var interactable = true

func _ready():
    var mat = sprite.get_material().duplicate(true)
    sprite.set_material(mat)
    connect("body_entered", self, "_on_body_entered")
    connect("body_exited", self, "_on_body_exited")
    player = get_tree().get_nodes_in_group("Player")[0]
    set_shader_color()
    set_process(false)

func set_shader_color(color=Color(0,0,0,0)):
    outline_color = color
    sprite.material.set_shader_param("outline_color", outline_color)

func interact():
    pass

func get_action_string():
    return

func _on_body_entered(body):
	if body == player && interactable:
		set_shader_color()
		body.queue_interactable(self, true)

func _on_body_exited(body):
	if body == player && interactable:
		set_shader_color()
		body.queue_interactable(self, false)