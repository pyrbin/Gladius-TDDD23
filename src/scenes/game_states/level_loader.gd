extends Node

export(PackedScene) var level_one
export(PackedScene) var level_two
export(PackedScene) var level_three
export(PackedScene) var level_four
export(PackedScene) var level_five

onready var root_level = $World/Root_Level
onready var wave_manager = null

func _ready():
    wave_manager = utils.singleton("WaveManager")
    var level = get_level().instance()
    root_level.add_child(level)
    wave_manager.load()
    level.connect("level_end", self, "_on_level_ended")
    level.connect("level_next", self, "_on_level_next")
    utils.get_player().connect("dead", self, "_on_player_dead")

func _on_player_dead(value):
    if not value: return
    utils.singleton("MainAudio").fade_out(game.theme_ambience)
    yield(utils.timer(3), "timeout")
    utils.scene_changer().transition("EndScreen.tscn")

func _on_level_ended():
    wave_manager.end()

func _on_level_next():
    var main_audio = utils.singleton("MainAudio")
    main_audio.fade_out(game.theme_ambience)
    if game.current_level == game.END_LEVEL:
        utils.scene_changer().transition("WinScreen.tscn")
    else:
        utils.scene_changer().transition("LevelSelect.tscn")

func current_level():
    return root_level.get_child(0)

func get_level():
    match game.current_level:
        1: return level_one
        2: return level_two
        3: return level_three
        4: return level_four
        5: return level_five
    return null

func get_game():
    return get_tree().get_nodes_in_group("Game")[0]
