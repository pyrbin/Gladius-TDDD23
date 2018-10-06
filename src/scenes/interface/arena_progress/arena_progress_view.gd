extends Control

onready var title = $Title
onready var press_start = $PressStart
onready var progress = $TextureProgress
onready var margin = 900/progress.max_value
onready var anim_player = $AnimationPlayer

export(Dictionary) var levels = {}

var _finished_anim = false

func _ready():
	$Tween.connect("tween_completed", self, "_on_tween_complete")
	for i in range(0, len(progress.get_children())):
		progress.get_child(i).rect_position = Vector2((margin+32)*(i) + (i+1)*-32, -64)
	title.hide(); press_start.hide()
	anim_player.play("flash")
	progress_to(0, 4)

func _input(event):
	if _finished_anim && event.is_action_pressed("ui_select"):
		print("PRESS START: " + String(selected_level()))

func selected_level():
	return int(progress.value)

func progress_to(start, end=null):
	if end == null: end = start
	if start == end+1: return
	_finished_anim = false
	title.hide(); press_start.hide()
	$Tween.interpolate_property(progress, "value", progress.value, start, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield(utils.timer(6), "timeout")
	progress_to(start+1, end)

func _on_tween_complete(a1, a2):
	for i in range(1, progress.value+2):
		if progress.value == i-1:
			title.show(); press_start.show()
			title.set_text(levels[i-1])
			_finished_anim = true
		progress.get_child(i-1).modulate = Color("#be2633")