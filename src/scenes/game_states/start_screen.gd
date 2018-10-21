extends Control

onready var label = $VBoxContainer/MarginContainer/Label
onready var start = $VBoxContainer/Start

func _ready():
    if not utils.singleton("MainAudio").playing:
        utils.play_sound(game.theme_ambience, utils.singleton("MainAudio"))
    label.set_text(CONFIG.get_game_title())
    game.reset()

func _on_Button_pressed():
    utils.scene_changer().transition("IntroScreen.tscn")

func _on_Exit_pressed():
    get_tree().quit()    