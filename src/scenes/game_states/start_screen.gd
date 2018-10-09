extends Control

onready var button = $Button

func _on_Button_pressed():
    get_tree().change_scene("res://scenes/game_states/LevelSelect.tscn")