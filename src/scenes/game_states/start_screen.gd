extends Control

onready var start = $VBoxContainer/Start

func _on_Button_pressed():
    utils.singleton("MainAudio").play()
    utils.scene_changer().transition("LevelSelect.tscn")
