extends Control

onready var wave_label = $VBoxContainer/WaveLabel
onready var wave_level = $VBoxContainer/WaveLevel

var level = null

func _ready():
	level = get_tree().get_nodes_in_group("Level")[0]
	$Title.set_text(level.level_name)
	gb_Utils.lock_player(true)
	$AnimationPlayer.play("screen_open")
	level.connect("level_end", self, "_on_level_end")
	wave_level.hide()
	wave_label.hide()

func _process(d):
	if level && level.current_wave > 0 && not level.ended:
		wave_level.show()
		wave_label.show()
		wave_level.set_text(String(level.current_wave) + "/" + String(level.total_wave))

func _on_level_end():
	gb_Utils.lock_player(true)
	$AnimationPlayer.play("wave_complete")
	wave_level.hide()
	wave_label.hide()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "screen_open":
		gb_Utils.lock_player(false)
	if anim_name == "wave_complete":
		$AnimationPlayer.play("screen_open")
