extends Control

onready var wave_label = $VBoxContainer/WaveLabel
onready var wave_level = $VBoxContainer/WaveLevel

var level = null

func _ready():
	wave_level.hide()
	wave_label.hide()

func load():
	level = get_level()
	$Title.set_text(level.level_name)
	show()
	utils.lock_player(true)
	$AnimationPlayer.play("screen_open")

func get_level():
	var root = get_tree().get_nodes_in_group("Root_Level")[0]
	if len(root.get_children()) != 1:
		return null
	return root.get_child(0)

func _process(d):
	if level && level.current_wave > 0 && not level.ended:
		wave_level.show()
		wave_label.show()
		wave_level.set_text(String(level.current_wave) + "/" + String(level.total_wave))

func end():
	utils.lock_player(true)
	$AnimationPlayer.play("wave_complete")
	wave_level.hide()
	wave_label.hide()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "screen_open":
		utils.lock_player(false)
	if anim_name == "wave_complete":
		$AnimationPlayer.play("screen_open")
