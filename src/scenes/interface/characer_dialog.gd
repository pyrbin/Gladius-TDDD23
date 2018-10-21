extends Control

signal is_done

onready var spectator = $Label/Position2D/Spectator
onready var dialog_label = $Label
onready var start = $Start

var done_talking = false

func _ready():
	dialog_label.connect("is_done", self, "_is_done_talking")
	start.hide();
	dialog_label.reset();
	hide()

func open_dialog(p_spectator=spectator):
	dialog_label.start = true
	spectator.skin_color = p_spectator.skin_color
	spectator.hair_color = p_spectator.hair_color
	spectator.dress_up(p_spectator.hair.texture, p_spectator.chest.texture)
	show();

func _input(event):
	if done_talking && event.is_action_pressed("ui_select"):
		hide();
		dialog_label.reset();
		done_talking = false
		emit_signal("is_done")

func _is_done_talking():
	$AnimPlayer.play("idle")
	done_talking = true
	start.show()
