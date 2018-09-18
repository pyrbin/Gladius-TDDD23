extends Node

export (Color) var pickup_color = Color(0,1,0)
#export(NodePath) onready var player_equipment_controller = get_node(player_equipment_controller)
onready var timer = $Timer

const PICKUP_RESET_VALUE = 999999

var player = null
var interact_enabled = false
# Item world object (not data object)
var to_interact = null
# Current lowest distance to character
var min_dist = PICKUP_RESET_VALUE
var player_was_dead = false

func _ready():
    player = owner
    player.connect("on_interactable_join", self, "_interactable_in_range")
    player.connect("on_interact", self, "_on_interact")

func _interactable_in_range():
    _set_interactable(true)

func _process(delta):

    if player.dead: 
        _set_interactable(false)
        return
    if player.interactable_list.size() == 0:
        _set_interactable(false)
        return
    elif not interact_enabled:
        _set_interactable(true)

    var player_pos = Vector2(player.global_position.x, player.global_position.y)
    for interactable in player.interactable_list:
        var dist = interactable.global_position.distance_to(player_pos)
        if (dist < min_dist && interactable != to_interact):
            min_dist = dist
            if (to_interact):
                to_interact.set_shader_color()
            to_interact = interactable

    if to_interact != null && timer.is_stopped():
        to_interact.set_shader_color(pickup_color)

func _set_interactable(b):
    interact_enabled = b
    min_dist = PICKUP_RESET_VALUE
    if (to_interact):
        to_interact.set_shader_color()
    to_interact = null

func _on_interact():
    if not to_interact or not timer.is_stopped(): return
    to_interact.interact()
    to_interact = null
    min_dist = PICKUP_RESET_VALUE
    timer.start()
