extends Control

onready var player = get_tree().get_nodes_in_group("Player")[0]
onready var interact_controller = player.get_node("InteractController")

var display = false
const DISPL_STR_START = \
"[center]Press [color=red](E)[/color] to "

func _ready():
	interact_controller.connect("interact_available", self, "_on_interact_available") 
	interact_controller.connect("interact_removed", self, "_on_interact_removed") 
	set_process(display)
	$Text.show() if display else $Text.hide()

func _process(d):
	$Text.set_bbcode(DISPL_STR_START + interact_controller.to_interact.get_action_string())

func _on_interact_available():
	display = true
	$Text.show() if display else $Text.hide()
	set_process(display)

func _on_interact_removed():
	display = false
	$Text.show() if display else $Text.hide()
	set_process(display)