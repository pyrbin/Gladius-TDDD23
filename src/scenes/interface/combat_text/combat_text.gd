extends Node2D

onready var is_active = false
onready var combat_text = $Base/Pivot/Text
onready var anim_player = $AnimationPlayer

func display(text, position, color, crit=false):
	is_active = true
	combat_text.add_color_override("font_color", color)
	combat_text.set_text(text)
	global_position.x = position.x + randi()%30-15
	global_position.y = position.y
	anim_player.play("display" if not crit else "crit")

func _on_AnimationPlayer_animation_finished(anim_name):
	is_active = false
	get_parent().remove_child(self)
