extends Control

onready var title = $Title
onready var press_start = $PressStart
onready var progress = $TextureProgress
onready var margin = 900/progress.max_value
onready var anim_player = $AnimationPlayer

signal selected_level()

export(Dictionary) var levels = {}

var _finished_anim = false

func _ready():
	$Tween.connect("tween_completed", self, "_on_tween_complete")
	for i in range(0, len(progress.get_children())):
		progress.get_child(i).rect_position = Vector2((margin+32)*(i) + (i+1)*-32, -64)
	title.hide(); press_start.hide(); hide()
	anim_player.play("flash")

func _input(event):
	if _finished_anim && event.is_action_pressed("ui_select"):
		hide()
		emit_signal("selected_level")

func selected_level():
	return int(progress.value)

func progress_to(start, end=null):
	if end == null: end = start
	show()
	_finished_anim = false
	title.hide(); press_start.hide()
	var speed = 1.5
	if end == 1: speed = 0.0001
	for i in range(0, start):
		progress.get_child(i).modulate = Color("#be2633")
	$Tween.interpolate_property(progress, "value", progress.value, start, speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_tween_complete(a1, a2):
	for i in range(1, progress.value+2):
		if progress.value == i-1:
			title.show(); press_start.show()
			title.set_text(levels[i-1])
			progress.get_child(i-1).modulate = Color("#be2633")
			_finished_anim = true
