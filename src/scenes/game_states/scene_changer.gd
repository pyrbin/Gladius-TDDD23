extends Node

func transition(scene):
	$Scene.remove_child($Scene.get_child(0))
	$Scene.add_child(load("res://scenes/game_states/"+scene).instance())