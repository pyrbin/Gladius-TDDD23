extends Control

onready var arena_progress = $ArenaProgressView

func _ready():
	arena_progress.connect("selected_level", self , "_on_level_selected")
	var current_level = game.current_level
	arena_progress.progress_to(current_level, current_level+1)

func _on_level_selected():
	game.current_level+=1
	get_tree().change_scene("res://scenes/game_states/Arena.tscn")
