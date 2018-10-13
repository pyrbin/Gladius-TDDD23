extends Area2D

signal interact

export (String) var interactable_name = ""
export (String) var action_string = "Interact with"
export (String) var object_string = ""
export (AudioStream) var sfx_interact
export (bool) var disabled = false setget set_disabled

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
    if has_node("CollisionShape2D"):
        $CollisionShape2D.disabled = disabled    
    set_shader_color()
    set_process(false)

func set_shader_color(color=Color(0,0,0,0)):
    outline_color = color
    sprite.material.set_shader_param("outline_color", outline_color)

func interact():
    if sfx_interact:
        print("SOUND")
        utils.play_sound(sfx_interact, $AudioPlayer)
    emit_signal("interact")

func set_disabled(val):
    disabled = val
    if has_node("CollisionShape2D"):
        $CollisionShape2D.disabled = disabled

func make_action_string(string):
    return "[color=green]"+string+"[/color]"

func get_action_string():
    return make_action_string(action_string) + " [color=lightblue]" + object_string if object_string != "" else interactable_name + "[/color] \n"

func _on_body_entered(body):
	if body == player && interactable:
		set_shader_color()
		body.queue_interactable(self, true)

func _on_body_exited(body):
	if body == player && interactable:
		set_shader_color()
		body.queue_interactable(self, false)