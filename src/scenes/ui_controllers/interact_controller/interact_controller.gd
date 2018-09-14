extends Control

export (Color) var pickup_color = Color(0,1,0)
export(NodePath) onready var player_equipment_controller = get_node(player_equipment_controller)
onready var item_pickup_label = $Interact_Label
onready var timer = $Timer

const PICKUP_RESET_VALUE = 999999

var player = null
var interact_enabled = false
# Item world object (not data object)
var to_interact = null
# Current lowest distance to character
var min_dist = PICKUP_RESET_VALUE

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	player.connect("on_interactable_join", self, "_interactable_in_range")
	player.connect("on_interact", self, "_on_interact")

func _interactable_in_range():
	_set_interactable(true)

func _process(delta):

	if player.interactable_list.size() == 0:
		_set_interactable(false)
		return

	var string = ""

	var player_pos = Vector2(player.global_position.x, player.global_position.y)

	for interactable in player.interactable_list:
		var dist = interactable.global_position.distance_to(player_pos)
		if (dist < min_dist && interactable != to_interact):
			min_dist = dist
			if (to_interact):
				to_interact.set_shader_color()
			to_interact = interactable

	if to_interact != null && timer.is_stopped():
		string = "Press [color=red][b]( E )[/b][/color] to "+to_interact.get_action_string()
		to_interact.set_shader_color(pickup_color)

	item_pickup_label.set_bbcode(string)

func _set_interactable(b):
	interact_enabled = b
	min_dist = PICKUP_RESET_VALUE
	if (to_interact):
		to_interact.set_shader_color()
	to_interact = null
	item_pickup_label.set_bbcode("")
	set_process(interact_enabled)

func _on_interact():
	if not to_interact or not timer.is_stopped(): return
	to_interact.interact()
	to_interact = null
	min_dist = PICKUP_RESET_VALUE
	timer.start()
