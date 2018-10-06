extends Control

onready var anim_player = $AnimationPlayer
onready var progress = $TextureProgress

var MAX_COMBO = 3

var unit

func _ready():
	unit = owner.owner
	unit.connect("combo", self, "_on_unit_combo")
	unit.connect("lost_combo", self, "_on_unit_lost_combo")
	progress.max_value = MAX_COMBO

func _on_unit_combo(combo):
	progress.value = combo
	
func _on_unit_lost_combo(combo):
	if combo == MAX_COMBO:
		gb_CombatText.simple_popup(4, unit.global_position)
	progress.value = 0
