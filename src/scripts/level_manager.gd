extends Node

export (Array, PackedScene) var levels = []

func get_game():
    return get_tree().get_nodes_in_group("Game")[0]

