extends "res://scenes/levels/level_manager.gd"

export (PackedScene) var boss;

func _ready():
	utils.singleton("CharacterDialog").connect("is_done", self, "_is_done_talking")

func spawn():
	yield(utils.timer(2), "timeout")
	var b = boss.instance()
	b.connect("dead", self, "_boss_dead")
	utils.singleton("Root_Units").add_child(b)
	utils.singleton("Boss_Healthbar").start(b)
	b.global_position = spawn_point.global_position

func _boss_dead(d):
	utils.get_player().invunerable = true
	utils.lock_player(true)
	yield(utils.timer(4), "timeout")
	utils.scene_changer().transition("WinScreen.tscn")


func _is_done_talking():
	var main_audio = utils.singleton("MainAudio")
	main_audio.fade_out(game.theme_main)
	utils.singleton("MainCameraPivot").target = false
	emit_signal("level_start")
	utils.lock_player(false);
	spawn()
	
func _on_banner_interact():
	utils.singleton("MainCameraPivot").target = utils.singleton("Ceasar")
	utils.lock_player(true);
	$Labels/BannerLabel.hide()
	banner_node.disabled = true
	utils.singleton("CharacterDialog").open_dialog(utils.singleton("Ceasar"))