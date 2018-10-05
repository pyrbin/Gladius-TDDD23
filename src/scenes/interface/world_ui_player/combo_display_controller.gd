extends Control

onready var anim_player = $AnimationPlayer
onready var label = $Label
onready var scale_player = $ScalePlayer

var unit
var comboed = false

func _ready():
	unit = owner.owner
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


func _on_ScalePlayer_animation_finished(anim_name):
	if anim_name == "zoom" && comboed:
		comboed = false
		_on_unit_lost_combo(0)
