extends Control

onready var anim_player = $AnimationPlayer
onready var label = $Label
onready var scale_player = $ScalePlayer

var unit

func _ready():
	unit = owner
	#anim_player.play("shake")
	unit.connect("combo", self, "_on_unit_combo")
	unit.connect("lost_combo", self, "_on_unit_lost_combo")
	label.hide()

func _on_unit_combo(combo):
	label.show()
	label.set_text("x"+String(combo))
	scale_player.play("zoom")

func _on_unit_lost_combo(combo):
	label.set_text("")
	label.hide()
