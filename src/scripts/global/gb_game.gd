extends Node

var theme_main = preload("res://assets/sounds/theme_main.ogg")
var theme_ambience = preload("res://assets/sounds/theme_ambience.ogg")

var current_level = 0
var player = null
var player_equipment = [0, 0, 0]
var player_weapons = [0, 0]

const END_LEVEL = 3

func reset():
    current_level = 0
    player = null
    player_equipment = [0, 0, 0]
    player_weapons = [0, 0]